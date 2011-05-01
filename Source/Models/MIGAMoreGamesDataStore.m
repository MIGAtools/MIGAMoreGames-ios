//
//  MIGAMoreGamesDataStore.m
//  MIGAMoreGames
//
//  Created by Darryl H. Thomas on 7/24/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "MIGALogging.h"
#import "MIGAAvailability.h"
#import "MIGAMoreGamesDataStore.h"
#import "JSON.h"
#import "MIGAPersistentCacheManager.h"
#import "MIGAURL.h"
#import "MIGAMoreGamesContentValidation.h"

#define MIGA_MORE_GAMES_DATA_STORE_WRITE_BATCH_SIZE 5
#define MIGA_MORE_GAMES_DATA_STORE_CONTENT_VERSION 1

NSString * const MIGAMoreGamesDataStoreDidUpdateNotification = @"MIGAMoreGamesDataStoreDidUpdate";

@interface MIGAMoreGamesCacheBackedDataStore : MIGAMoreGamesDataStore
{
}

@end

@interface MIGAMoreGamesDataStore ()

@property (nonatomic, retain) NSMutableArray *applications;

-(void)setApplicationsWithDictionary: (NSDictionary *)dictionary;
-(void)setApplicationsWithJSONString: (NSString *)json;
-(BOOL)setApplicationsWithContentsOfFile: (NSString *)filePath encoding: (NSStringEncoding)encoding error: (NSError **)error;
-(BOOL)setApplicationsWithContentsOfURL: (NSURL *)url encoding: (NSStringEncoding)encoding error: (NSError **)error;
-(void)setApplicationsWithAsynchronousRequestToURL: (NSURL *)url;
-(BOOL)setApplicationsWithDefaultContent;
-(BOOL)validateContent: (id)contentObject;
@end

@implementation MIGAMoreGamesDataStore

#pragma mark -
#pragma mark Properties

@synthesize applications;

-(NSMutableArray *)applications;
{
	if (!applications) {
		applications = [[NSMutableArray alloc] initWithCapacity: 3];
	}
	
	return applications;
}

-(NSUInteger)count;
{
	return [self.applications count];
}

#pragma mark -
#pragma mark Instance Methods

-(id)initWithJSONString: (NSString *)json;
{
	if ((self = [self init])) {
		[self setApplicationsWithJSONString: json];
	}
	
	return self;
}

-(id)initWithContentsOfFile:(NSString *)filePath encoding:(NSStringEncoding)encoding error:(NSError **)error;
{
	if ((self = [self init])) {
		[self setApplicationsWithContentsOfFile: filePath encoding: encoding error: error];
	}
	
	return self;
}

-(id)initWithAsynchronousRequestToURL: (NSURL *)url;
{
	return [self initWithAsynchronousRequestToURL: url cacheManager: nil];
}

-(id)initWithAsynchronousRequestToURL:(NSURL *)url cacheManager: (MIGAPersistentCacheManager *)aCacheManager;

{
	if ((self = [self init])) {
		cacheManager = [aCacheManager retain];
		if (cacheManager) {
			isa = [MIGAMoreGamesCacheBackedDataStore class];
		}
		requestedURL = [url retain];
		[self setApplicationsWithAsynchronousRequestToURL: url];
	}
	
	return self;	
}

-(id)initWithDefaultContent;
{
	if ((self = [self init])) {
		[self setApplicationsWithDefaultContent];
	}
	
	return self;
}

-(void)dealloc;
{
	[applications release];
	[cacheManager release];
	[request release];
	[requestedURL release];

	[super dealloc];
}

-(MIGAApplicationInfo *)applicationAtIndex: (NSUInteger)index;
{
	if (index >= [self.applications count])
		return nil;
	
	return [self.applications objectAtIndex: index];
}

-(void)setApplicationsWithDictionary: (NSDictionary *)dictionary;
{
	assert([[dictionary objectForKey: @"version"] intValue] == MIGA_MORE_GAMES_DATA_STORE_CONTENT_VERSION);
	
	[self.applications removeAllObjects];
	for (NSDictionary *appDictionary in [dictionary objectForKey: @"apps"]) {
		[self.applications addObject: [[[MIGAApplicationInfo alloc] initWithContentsOfDictionary: appDictionary] autorelease]];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName: MIGAMoreGamesDataStoreDidUpdateNotification object: self];	
}

-(void)setApplicationsWithJSONString: (NSString *)json;
{
	id parsedJSON = [json JSONValue];
	
	if ([self validateContent: parsedJSON])
		[self setApplicationsWithDictionary: parsedJSON];
}

-(BOOL)setApplicationsWithContentsOfFile: (NSString *)filePath encoding: (NSStringEncoding)encoding error: (NSError **)error;
{
	return [self setApplicationsWithContentsOfURL: [NSURL fileURLWithPath: filePath] encoding: encoding error: error];
}

-(BOOL)setApplicationsWithContentsOfURL: (NSURL *)url encoding: (NSStringEncoding)encoding error: (NSError **)error;
{
	NSString * json = [NSString stringWithContentsOfURL: url encoding: encoding error: error];
	
	if (!json)
		return NO;
	
	[self setApplicationsWithJSONString: json];
	
	return YES;
}

-(void)setApplicationsWithAsynchronousRequestToURL: (NSURL *)url;
{
	MIGADLog(@"Sending request for %@ ...", [url description]);
	[request release];
	
	NSString *platformName = @"IPHONE";
#if MIGA_IOS_3_2_SUPPORTED
	if (([[UIDevice currentDevice] respondsToSelector: @selector(userInterfaceIdiom)]) && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)) {
		platformName = @"IPAD";
	}
#endif
	
	NSDictionary *requestDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
																		 [NSNumber numberWithInt: 1], @"version",
																		 [[NSBundle mainBundle] bundleIdentifier], @"package",
																		 [[UIDevice currentDevice] uniqueIdentifier], @"device_id",
																		 platformName, @"platform",
#ifdef DEBUG
																		 [NSNumber numberWithInt: 1], @"test_mode",
#endif
																		 nil];
	
	NSString *json = [requestDictionary JSONRepresentation];
	NSDictionary *postDictionary = [NSDictionary dictionaryWithObject: json forKey: @"request"];
	
	request = [[MIGAAsyncHttpRequest requestWithURL: url postDictionary: postDictionary delegate: self] retain];
	// If the delegate was unset during instantiation, we know there
	// a failure in the interim.
	if (request.delegate == nil) {
		[request release];
		request = nil;
	}
}

-(BOOL)setApplicationsWithDefaultContent;
{
	MIGAURL *url = [MIGAURL URLWithString: @"miga-bundle:///MIGAMoreGamesDefaultContent/content.json"];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath: [url path]]) {
		MIGADLog(@"Unable to set applications with default content.  No content feed file found at path: %@", [url path]);
		return NO;
	}
	
	MIGADLog(@"Using default content feed file found at path: %@", [url path]);
	return [self setApplicationsWithContentsOfURL: url encoding: NSUTF8StringEncoding error: NULL];
}

-(BOOL)writeToFile: (NSString *)filePath encoding: (NSStringEncoding)encoding error: (NSError **)error;
{
	NSMutableArray *appsArray = [[NSMutableArray alloc] initWithCapacity: [self.applications count]];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSUInteger batchCount = 0;
	
	for (MIGAApplicationInfo *app in self.applications) {
		
		[appsArray addObject: [app dictionaryValue]];
	
		batchCount++;
		
		if (batchCount >= MIGA_MORE_GAMES_DATA_STORE_WRITE_BATCH_SIZE) {
			[pool release];
			pool = [[NSAutoreleasePool alloc] init];
		}
	}
	[pool release];
	
	NSString *jsonString = [[NSDictionary dictionaryWithObjectsAndKeys:
														[NSNumber numberWithInt: MIGA_MORE_GAMES_DATA_STORE_CONTENT_VERSION], @"version",
														appsArray, @"apps",
														nil] JSONRepresentation];
	[appsArray release];
	
	return [jsonString writeToFile: filePath atomically: YES encoding: encoding error: error];
}

-(void)update;
{
	if ((request == nil) && (requestedURL != nil)) {
		[self setApplicationsWithAsynchronousRequestToURL: requestedURL];
	}
}

#pragma mark -
#pragma mark AsyncHttpRequestDelegate Methods

-(void)asyncHttpRequest:(MIGAAsyncHttpRequest *)aRequest didFinishWithContent:(NSData *)responseContent;
{
	if (aRequest != request)
		return;
	
	NSString *responseString = [[NSString alloc] initWithData: responseContent encoding: request.receivedStringEncoding];
	[self setApplicationsWithJSONString: responseString];
	[responseString release];
	[request release];
	request = nil;
}

-(void)asyncHttpRequestDidFail:(MIGAAsyncHttpRequest *)aRequest;
{
	[request release];
	request = nil;
	
	MIGADLog(@"MIGAMoreGamesDataStore: Asynchronous application JSON request failed. Will attempt to fall back to default content.");
	
	[self setApplicationsWithDefaultContent];
}

-(BOOL)validateContent: (id)contentObject;
{
	BOOL result = MIGAMoreGamesContentValidationValidateContentObject(contentObject);
	if (!result) {
		MIGADLog(@"Content object validation failed.");
		return NO;
	}
	
	MIGADLog(@"Content object validation succeeded.");
	return YES;
}

@end


@implementation MIGAMoreGamesCacheBackedDataStore

-(void)setApplicationsWithAsynchronousRequestToURL: (NSURL *)url;
{
	MIGADLog(@"Attempting to obtain object for %@ from cache...", [url description]);
	
	BOOL objectIsExpired = NO;
	if ([cacheManager cachedObjectExistsForURL: url isExpired: &objectIsExpired]) {
	
		if (!objectIsExpired) {
			MIGADLog(@"Cache hit for %@.", [url description]);
			NSDictionary *cachedDictionary = (NSDictionary *)[cacheManager objectForURL: url];
			[self setApplicationsWithDictionary: cachedDictionary];
			
			return;
			
		}
		
		MIGADLog(@"Cached item for %@ is stale.  Will attempt to fetch.", [url description]);
	} else {
		MIGADLog(@"Cache miss for %@. Will attempt to fetch.", [url description]);
	}
	
	[super setApplicationsWithAsynchronousRequestToURL: url];
}

#pragma mark -
#pragma mark AsyncHttpRequestDelegate Methods

-(void)asyncHttpRequest:(MIGAAsyncHttpRequest *)aRequest didFinishWithContent:(NSData *)responseContent;
{
	if (aRequest != request)
		return;
	NSString *responseString = [[NSString alloc] initWithData: responseContent encoding: request.receivedStringEncoding];
	id parsedJSON = [responseString JSONValue];
	[responseString release];
	
	if ([self validateContent: parsedJSON]) {
		NSTimeInterval expireAt = [parsedJSON objectForKey: @"expire_at"] ? [[parsedJSON objectForKey: @"expire_at"] doubleValue] : 0;
		NSTimeInterval purgeAt = [parsedJSON objectForKey: @"purge_at"] ? [[parsedJSON objectForKey: @"purge_at"] doubleValue] : 0;
		MIGADLog(@"Caching parsed json for URL: %@.  Will expire at %f and purge at %f (or global values if global values are earlier).", [aRequest.requestedURL description], expireAt, purgeAt);
		[cacheManager setObject: parsedJSON forURL: aRequest.requestedURL expireAt: expireAt purgeAt: purgeAt];
		[self setApplicationsWithDictionary: parsedJSON];
	} else {
		[self asyncHttpRequestDidFail: aRequest];
	}

	[request release];
	request = nil;
}

-(void)asyncHttpRequestDidFail:(MIGAAsyncHttpRequest *)aRequest;
{		
	MIGADLog(@"Asynchronous application JSON request failed.  Attempting to obtain stale object from cache.");

	NSURL *url = aRequest.requestedURL;

	NSDictionary *cachedDictionary = (NSDictionary *)[cacheManager objectForURL: url];
	if (cachedDictionary) {
		MIGADLog(@"Stale cache hit for %@", [url description]);

		[request release];
		request = nil;

		[self setApplicationsWithDictionary: cachedDictionary];
		return;
	}

	MIGADLog(@"Stale cache miss for %@", [url description]);
	[super asyncHttpRequestDidFail: aRequest];
}

@end