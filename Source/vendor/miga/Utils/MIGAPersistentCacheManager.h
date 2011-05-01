//
//  MIGAPersistentCacheManager.h
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 7/26/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kMIGAPersistentCacheManagerDefaultCacheDirectoryName;

#ifdef DEBUG // When debugging, cache age limits are 2 and 4 minutes
#define MIGA_PERSISTENT_CACHE_MANAGER_DEFAULT_EXPIRY_AGE 120
#define MIGA_PERSISTENT_CACHE_MANAGER_DEFAULT_MAXIMUM_AGE 240

#else // Production age limits are more sensible
#define MIGA_PERSISTENT_CACHE_MANAGER_DEFAULT_EXPIRY_AGE 604800 // 7 days
#define MIGA_PERSISTENT_CACHE_MANAGER_DEFAULT_MAXIMUM_AGE 2592000 // 30 days
#endif

/*!
 @class MIGAPersistentCacheManager
 
 @abstract MIGAPersistentCacheManager is a simple mechanism
 for archiving and unarchiving objects associated with a given URL.
 
 @discussion The cache manager is a very basic implementation of a
 persistent cache.  When an object is set for a given URL, the object
 is archived to a file.  An index dictionary keeps track of the cached
 objects as well as some metadata (update timestamp, etc).
 
 The index is written to a file periodically (including upon app
 termination/backgrounding).  When a cache manager is instantiated for a
 given cache directory, the index file is used to reestablish the
 mapping between URLS and objects, meaning the cache remains useful
 across multiple application runs.
 
 It is *not* safe to instantiate multiple cache managers for the same
 directory.
 
 The cache manager is not intended to store the raw content from an
 HTTP response, but rather an object that represents how said content
 will be used.  To clarify, if an HTTP request was made for an image
 resource and that image was a PNG file, the content that gets cached
 would not be a PNG file or even an instance of UIImage, but rather
 an NSData object containing the image data.  The cache manager can only
 persist objects conforming to the NSCoding protocol.
 
 The primary benefit of this type of storage model is that objects can
 be persisted to the cache AFTER the the remote resource has been
 transformed into something useful to the application.  For example,
 instead of persisting a raw HTTP response containing a JSON string,
 the object resulting from the parsing of said string can be persisted.
 
 The cache manager has two properties governing the age of items in the
 cache: expiryAge and maximumAge.  When the age of a given item exceeds
 the expiryAge, it will still be considered a cache hit and the stale
 object will be returned.  When the age of a given item exceeds the
 maximumAge, it will be considered a cache miss and any data stored for
 that item will be purged from the cache.  This allows the developer to
 retrieve cached items as a fallback when network access is not
 available while still allowing for a true maximum expiry.
 
 Cached items may have individual expiry and purging timestamps.  If a
 cached item has a specified expiry or purging timestamp, the lesser of
 the individual and global governors will determine the caching behavior.
 (Note that values less than or equal to 0 are treated as unset.)
 */
@interface MIGAPersistentCacheManager : NSObject {
	@private
	NSMutableDictionary *cacheIndex;
	NSString *cacheDirectory;
	NSString *objectDirectory;
	
	NSTimeInterval expiryAge;
	NSTimeInterval maximumAge;
	
	BOOL isDirty;
}

+(NSString *)defaultPersistentCacheDirectory;

+(id)defaultManager;
+(id)managerWithCacheDirectory: (NSString *) cacheDirectory;

@property (nonatomic, retain, readonly) NSString * cacheDirectory;
@property (nonatomic, assign) NSTimeInterval expiryAge;
@property (nonatomic, assign) NSTimeInterval maximumAge;

-(id)initWithCacheDirectory: (NSString *) cacheDirectory;

-(BOOL)cachedObjectExistsForURL: (NSURL *)url isExpired: (BOOL *)expired;
-(id<NSCoding>)objectForURL: (NSURL *)url;
-(void)setObject: (id<NSCoding>)item forURL: (NSURL *)url;
-(void)setObject: (id<NSCoding>)object forURL: (NSURL *)url expireAt: (NSTimeInterval)expireAtIntervalSince1970 purgeAt: (NSTimeInterval)purgeAtIntervalSince1970;

-(void)cleanUpStorage;

-(BOOL)writeIndexToFile;
-(BOOL)writeIndexToFileIfNeeded;

@end
