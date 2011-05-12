//
//  MIGAMoreGamesDataStore.h
//  MIGAMoreGames
//
//  Created by Darryl H. Thomas on 7/24/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIGAAsyncHttpRequest.h"
#import "MIGAApplicationInfo.h"

@class MIGAPersistentCacheManager;

/*!
 A MIGAMoreGamesDataStoreDidUpdateNotifcation is posted when the list of
 applications changes.  No notificationInfo is included in the notification.
 
 When asynchronous requests are used to fetch the applications list, interested
 parties should add an observer for this notification which will fire once
 the request has completed and the data store has been updated.
*/
extern NSString * const MIGAMoreGamesDataStoreDidUpdateNotification;

/*!
 A MIGAMoreGamesDataStoreDidFailLoadingNotification is posted once all
 content loading options have been exhausted and no content has been loaded.

*/
extern NSString * const MIGAMoreGamesDataStoreDidFailLoadingNotification;

/*!
 @class MIGAMoreGamesDataStore
 
 @abstract A MIGAMoreGamesDataStore maintains a collection of MIGAApplicationInfo
 objects, providing mechanisms for loading application info from various sources
 and persisting application info to a file.
 
 @discussion MIGAMoreGamesDataStore supports the use of a cache manager.  When
 instantiated with a cache manager, MIGAMoreGamesDataStore is isa-swizzled to
 a cache-backed subclass.  This prevents non-cache-backed instances from
 incurring any additional overhead from cache checks, etc.
 
 When cache-backed, MIGAMoreGamesDataStore will attempt to resolve requested
 URLS to a cached item before making an HTTP request. If a non-stale object is
 available, the datastore will forego an HTTP request.  If a stale object is
 available, the datastore will attempt an HTTP request, but upon failure the
 stale object will be used.  If no cached item is available (or the item is
 older than the maximum age defined by the cache manager), the datastore will
 attempt an HTTP request and failures will behave as though the datastore was
 not cache-backed.
 
 Upon successful retrieval of an object resulting from an HTTP request, a
 cache-backed datastore will update the cache with the result for future use.
 
*/
@interface MIGAMoreGamesDataStore : NSObject <MIGAAsyncHttpRequestDelegate> {
	@protected
	NSMutableArray *_applications;
	MIGAPersistentCacheManager *_cacheManager;
	MIGAAsyncHttpRequest *_request;
	
	NSURL *_requestedURL;
}

@property (nonatomic,assign,readonly) NSUInteger count;

- (id)initWithJSONString:(NSString *)json;
- (id)initWithContentsOfFile:(NSString *)filePath encoding:(NSStringEncoding)encoding error:(NSError **)error;

- (id)initWithAsynchronousRequestToURL:(NSURL *)url;
- (id)initWithAsynchronousRequestToURL:(NSURL *)url cacheManager:(MIGAPersistentCacheManager *)cacheManager;

- (id)initWithDefaultContent;

- (MIGAApplicationInfo *)applicationAtIndex:(NSUInteger)index;

- (BOOL)writeToFile:(NSString *)filePath encoding:(NSStringEncoding)encoding error:(NSError **)error;

- (void)update;

@end
