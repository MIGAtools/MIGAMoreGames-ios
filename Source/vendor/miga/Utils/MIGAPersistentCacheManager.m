//
//  MIGAPersistentCacheManager.m
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 7/26/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "MIGALogging.h"
#import "MIGAPersistentCacheManager.h"
#import "NSString+migaUUID.h"

NSString * const kMIGAPersistentCacheManagerDefaultCacheDirectoryName = @"MIGAPersistentCacheDefault";

static NSString *defaultCacheDirectory = nil;
static NSMutableDictionary *managers = nil;

@interface MIGAPersistentCacheItem : NSObject<NSCoding>
{
	@private
	NSString *uuidString;
	NSTimeInterval expireAtTimestamp;
	NSTimeInterval purgeAtTimestamp;
	NSTimeInterval lastUpdate;
	NSURL *itemURL;
}

@property (nonatomic, retain, readonly) NSString *uuidString;
@property (nonatomic, assign, readwrite) NSTimeInterval expireAtTimestamp;
@property (nonatomic, assign, readwrite) NSTimeInterval purgeAtTimestamp;
@property (nonatomic, assign, readwrite) NSTimeInterval lastUpdate;
@property (nonatomic, retain, readwrite) NSURL *itemURL;

@property (nonatomic, assign, readonly) BOOL isStale;
@property (nonatomic, assign, readonly) BOOL isDead;

-(NSTimeInterval)age;

@end

@implementation MIGAPersistentCacheItem

@synthesize expireAtTimestamp;
@synthesize purgeAtTimestamp;
@synthesize lastUpdate;
@synthesize itemURL;

-(NSString *)uuidString;
{
	if (!uuidString) {
		uuidString = [[NSString migaUUIDString] retain];
	}
	
	return uuidString;
}

-(BOOL)isStale;
{
	return ((self.expireAtTimestamp > 0) && ([[NSDate date] timeIntervalSince1970] > self.expireAtTimestamp));
}

-(BOOL)isDead;
{
	return ((self.purgeAtTimestamp > 0) && ([[NSDate date] timeIntervalSince1970] > self.purgeAtTimestamp));	
}

-(id)initWithCoder:(NSCoder *)aDecoder;
{
	if ((self = [super init])) {
		uuidString = [[aDecoder decodeObjectForKey: @"uuidString"] retain];
		expireAtTimestamp = [aDecoder decodeDoubleForKey: @"expireAtTimestamp"];
		purgeAtTimestamp = [aDecoder decodeDoubleForKey: @"purgeAtTimestamp"];
		lastUpdate = [aDecoder decodeDoubleForKey: @"lastUpdate"];
		itemURL = [[aDecoder decodeObjectForKey: @"itemURL"] retain];
	}
	
	return self;
}

-(void)dealloc;
{
	[itemURL release];
	[uuidString release];
	
	[super dealloc];
}

-(void)encodeWithCoder: (NSCoder *)encoder;
{
	[encoder encodeObject: self.uuidString forKey: @"uuidString"];
	[encoder encodeDouble: self.expireAtTimestamp forKey: @"expireAtTimestamp"];
	[encoder encodeDouble: self.purgeAtTimestamp forKey: @"purgeAtTimestamp"];
	[encoder encodeDouble: self.lastUpdate forKey: @"lastUpdate"];
	[encoder encodeObject: self.itemURL forKey: @"itemURL"];
}

-(NSTimeInterval)age;
{
	NSTimeInterval result = ([[NSDate date] timeIntervalSince1970] - self.lastUpdate);

	return result;
}

@end

@interface MIGAPersistentCacheManager ()

@property (nonatomic, retain, readonly) NSMutableDictionary *cacheIndex;
@property (nonatomic, retain, readonly) NSString *cacheIndexFilePath;
@property (nonatomic, retain, readonly) NSString *objectDirectory;

-(void)purgeItem: (MIGAPersistentCacheItem *)item;

-(void)handleUIApplicationWillTerminateNotification: (NSNotification *)notification;
-(void)handleUIApplicationDidEnterBackgroundNotification: (NSNotification *)notification;

@end


@implementation MIGAPersistentCacheManager
@synthesize cacheDirectory;
@synthesize maximumAge, expiryAge;

-(NSString *)objectDirectory;
{
	if (!objectDirectory) {
		objectDirectory = [[self.cacheDirectory stringByAppendingPathComponent: @"objects"] retain];
	}
	
	return objectDirectory;
}

-(NSString *)cacheIndexFilePath;
{
	return [self.cacheDirectory stringByAppendingPathComponent: @"index.plist"];
}

-(NSMutableDictionary *)cacheIndex;
{
	if (!cacheIndex) {
		NSDictionary * savedDictonary = [NSDictionary dictionaryWithContentsOfFile: self.cacheIndexFilePath];
		if (savedDictonary) {
			cacheIndex = [savedDictonary mutableCopy];
		} else {
			cacheIndex = [[NSMutableDictionary alloc] init];
		}
	}
	
	return cacheIndex;
}

+(NSString *)defaultPersistentCacheDirectory;
{
	return defaultCacheDirectory;
}

+(void)initialize;
{
	if (self == [MIGAPersistentCacheManager class]) {
		NSString * appCachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
		
		defaultCacheDirectory = [[appCachesDirectory stringByAppendingPathComponent: kMIGAPersistentCacheManagerDefaultCacheDirectoryName] retain];
		
		managers = [[NSMutableDictionary alloc] init];
	}
}

+(id)defaultManager;
{
	return [self managerWithCacheDirectory: [self defaultPersistentCacheDirectory]];
}

+(id)managerWithCacheDirectory: (NSString *) cacheDirectory;
{
	id result = [managers objectForKey: cacheDirectory];
	
	if (!result) {
		result = [[[self alloc] initWithCacheDirectory: cacheDirectory] autorelease];
		[managers setObject: result forKey: cacheDirectory];
	}
	
	return result;
}

-(id)initWithCacheDirectory: (NSString *) aCacheDirectory;
{
	if ((self = [super init])) {
		expiryAge = MIGA_PERSISTENT_CACHE_MANAGER_DEFAULT_EXPIRY_AGE;
		maximumAge = MIGA_PERSISTENT_CACHE_MANAGER_DEFAULT_MAXIMUM_AGE;
		cacheDirectory = [aCacheDirectory retain];
		
		NSFileManager * fileManager = [NSFileManager defaultManager];
		
		BOOL isDirectory = NO;
		NSError *error = nil;
		
		if (![fileManager fileExistsAtPath: self.objectDirectory isDirectory:&isDirectory]) {
			if (![fileManager createDirectoryAtPath: self.objectDirectory withIntermediateDirectories: YES attributes: nil error: &error]) {
				MIGAALog(@"Unable to initialize cache manager: %@", [error localizedDescription]);
				[self release];
				self = nil;
				return self;
			}
		} else {
			if (!isDirectory) {
				MIGAALog(@"Cache location already exists but is not a directory!");
				[self release];
				self = nil;
				return self;
			}
		}
		
		NSString * indexFilePath = [self.cacheDirectory stringByAppendingPathComponent: @"index.plist"];
		if ([fileManager fileExistsAtPath: indexFilePath]) {
			
			cacheIndex = [[NSKeyedUnarchiver unarchiveObjectWithFile: indexFilePath] mutableCopy];
			
		}
		
		isDirty = NO;
		
		NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
		[center addObserver: self selector: @selector(handleUIApplicationWillTerminateNotification:) name: UIApplicationWillTerminateNotification object: nil];
		
#if MIGA_IOS_4_0_SUPPORTED
		BOOL supportsBackgrounding = (&UIApplicationDidEnterBackgroundNotification != NULL);
		if (supportsBackgrounding) {
			[center addObserver: self selector: @selector(handleUIApplicationDidEnterBackgroundNotification:) name: UIApplicationDidEnterBackgroundNotification object: nil];
		}
#endif
		
		[NSTimer scheduledTimerWithTimeInterval: 0 target: self selector: @selector(cleanUpStorage) userInfo: nil repeats: NO];
		[NSTimer scheduledTimerWithTimeInterval: 30 target: self selector: @selector(writeIndexToFileIfNeeded) userInfo: nil repeats: YES];
	}
	
	return self;
}

-(void)dealloc;
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[self writeIndexToFileIfNeeded];

	[cacheIndex release];
	[cacheDirectory release];
	[objectDirectory release];

	[super dealloc];
}

-(id<NSCoding>)objectForURL: (NSURL *)url;
{
	MIGAPersistentCacheItem * item = [self.cacheIndex objectForKey: url];
	
	if (!item)
		return nil;
	
	BOOL itemIsTooOld = [item age] > self.maximumAge;	
	if (itemIsTooOld) {
		[self purgeItem: item];
		return nil;
	}
	
	id<NSCoding> result = [NSKeyedUnarchiver unarchiveObjectWithFile: [self.objectDirectory stringByAppendingPathComponent: item.uuidString]];
	
	return result;
}

-(void)setObject: (id<NSCoding>)object forURL: (NSURL *)url;
{
	[self setObject: object forURL: url expireAt: 0 purgeAt: 0];
}

-(void)setObject: (id<NSCoding>)object forURL: (NSURL *)url expireAt: (NSTimeInterval)expireAtTimestamp purgeAt: (NSTimeInterval)purgeAtTimestamp;
{
	MIGAPersistentCacheItem * item = [self.cacheIndex objectForKey: url];
	
	if (!item) {
		item = [[[MIGAPersistentCacheItem alloc] init] autorelease];
	}
	
	item.lastUpdate = [[NSDate date] timeIntervalSince1970];
	item.expireAtTimestamp = expireAtTimestamp;
	item.purgeAtTimestamp = purgeAtTimestamp;
	item.itemURL = url;
	
	[NSKeyedArchiver archiveRootObject: object toFile: [self.objectDirectory stringByAppendingPathComponent: item.uuidString]];
	
	[self.cacheIndex setObject: item forKey: url];
	isDirty = YES;	
}

-(BOOL)cachedObjectExistsForURL: (NSURL *)url isExpired: (BOOL *)expired;
{
	MIGAPersistentCacheItem * item = [self.cacheIndex objectForKey: url];
	
	if (item) {
		NSTimeInterval age = [item age];
		
		if (age > self.maximumAge) {
			[self purgeItem: item];
			*expired = YES;
			return NO;
		}
		
		*expired = item.isStale || ([item age] > self.expiryAge);
		return YES;
	}
	
	return NO;
}

-(void)purgeItem: (MIGAPersistentCacheItem *)item;
{
	NSString *filePath = [self.objectDirectory stringByAppendingPathComponent: item.uuidString];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSError *error = nil;
	if ([fileManager fileExistsAtPath: filePath] && ![fileManager removeItemAtPath: filePath error: &error]) {
		// TODO: change this to a MIGADLog call after testing
		MIGAALog(@"Unable to purge cache item with URL '%@' and UUID '%@': %@", item.itemURL, item.uuidString, [error localizedDescription]);
		return;
	}
	
	MIGADLog(@"Purging object for URL: %@", item.itemURL);
	[self.cacheIndex removeObjectForKey: item.itemURL];
	isDirty = YES;
}

-(void)cleanUpStorage;
{
	NSArray *urls = [self.cacheIndex allKeys];
	NSMutableArray *knownUUIDs = [[NSMutableArray alloc] initWithCapacity: [urls count]];
	
	// Check for and purge items exceeding maximum age
	for (id url in urls) {
		MIGAPersistentCacheItem *item = [self.cacheIndex objectForKey: url];
		BOOL itemIsTooOld = item.isDead || ([item age] > self.maximumAge);
		if (itemIsTooOld) {
			[self purgeItem: item];
		} else {
			[knownUUIDs addObject: item.uuidString];
		}
	}
	
	// Delete any orphaned files (files with no item object in the cache index)
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *objectFiles = [fileManager contentsOfDirectoryAtPath: self.objectDirectory error: NULL];
	for (NSString *file in objectFiles) {
		if ([knownUUIDs indexOfObject: file] == NSNotFound) {
			MIGADLog(@"Removing orphaned cache file: %@", file);
			[fileManager removeItemAtPath: [self.objectDirectory stringByAppendingPathComponent: file] error: NULL];
		}
	}
	
	[knownUUIDs release];
}

-(BOOL)writeIndexToFileIfNeeded;
{
	if (!isDirty)
		return NO;
	
	return [self writeIndexToFile];
}

-(BOOL)writeIndexToFile;
{
	BOOL result = [NSKeyedArchiver archiveRootObject: self.cacheIndex toFile: self.cacheIndexFilePath];
	
	if (!result) {
		MIGAALog(@"Unable to write cache index to file: %@", self.cacheIndexFilePath);
	} else {
		MIGADLog(@"Wrote index to file: %@", self.cacheIndexFilePath);
		isDirty = NO;
	}
		
	return result;
}

-(void)handleUIApplicationWillTerminateNotification: (NSNotification *)notification;
{
	MIGADLog(@"Calling -writeIndexToFileIfNeeded");
	[self writeIndexToFileIfNeeded];
	MIGADLog(@"Returned from -writeIndexToFileIfNeeded");
}

-(void)handleUIApplicationDidEnterBackgroundNotification:(NSNotification *)notification;
{
	MIGADLog(@"Calling -writeIndexToFileIfNeeded");
	[self writeIndexToFileIfNeeded];
	MIGADLog(@"Returned from -writeIndexToFileIfNeeded");
}

@end
