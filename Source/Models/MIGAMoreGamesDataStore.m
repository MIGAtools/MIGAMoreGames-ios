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
NSString * const MIGAMoreGamesDataStoreDidFailLoadingNotification = @"MIGAMoreGamesDataStoreDidFailLoading";

@interface MIGAMoreGamesCacheBackedDataStore : MIGAMoreGamesDataStore
{
}

@end

@interface MIGAMoreGamesDataStore ()

@property (nonatomic,retain) NSMutableArray *applications;

- (void)setApplicationsWithDictionary:(NSDictionary *)dictionary;
- (void)setApplicationsWithJSONString:(NSString *)json;
- (BOOL)setApplicationsWithContentsOfFile:(NSString *)filePath encoding:(NSStringEncoding)encoding error:(NSError **)error;
- (BOOL)setApplicationsWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)encoding error:(NSError **)error;
- (void)setApplicationsWithAsynchronousRequestToURL:(NSURL *)url;
- (BOOL)setApplicationsWithDefaultContent;
- (BOOL)validateContent:(id)contentObject;

@end

@implementation MIGAMoreGamesDataStore

#pragma mark -
#pragma mark Properties

@synthesize applications=_applications;
@synthesize failed=_failed;

- (NSMutableArray *)applications {
    if (!_applications) {
        _applications = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    return _applications;
}


- (NSUInteger)count {
    return [self.applications count];
}

- (BOOL)isRequesting {
    return (_request != nil);
}

#pragma mark -
#pragma mark Instance Methods

- (id)initWithJSONString:(NSString *)json {
    if ((self = [self init])) {
        [self setApplicationsWithJSONString:json];
    }
    
    return self;
}


- (id)initWithContentsOfFile:(NSString *)filePath encoding:(NSStringEncoding)encoding error:(NSError **)error {
    if ((self = [self init])) {
        [self setApplicationsWithContentsOfFile:filePath encoding:encoding error:error];
    }
    
    return self;
}


- (id)initWithAsynchronousRequestToURL:(NSURL *)url {
    return [self initWithAsynchronousRequestToURL:url cacheManager:nil];
}


- (id)initWithAsynchronousRequestToURL:(NSURL *)url cacheManager:(MIGAPersistentCacheManager *)cacheManager {
    if ((self = [self init])) {
        _cacheManager = [cacheManager retain];
        if (_cacheManager) {
            isa = [MIGAMoreGamesCacheBackedDataStore class];
        }
        _requestedURL = [url retain];
        [self setApplicationsWithAsynchronousRequestToURL:url];
    }
    
    return self;	
}


- (id)initWithDefaultContent {
    if ((self = [self init])) {
        [self setApplicationsWithDefaultContent];
    }
    
    return self;
}


- (void)dealloc {
    [_applications release];
    [_cacheManager release];
    [_request release];
    [_requestedURL release];

    [super dealloc];
}


- (MIGAApplicationInfo *)applicationAtIndex:(NSUInteger)index {
    if (index >= [self.applications count])
        return nil;
    
    return [self.applications objectAtIndex:index];
}


- (void)setApplicationsWithDictionary:(NSDictionary *)dictionary {
    assert([[dictionary objectForKey:@"version"] intValue] == MIGA_MORE_GAMES_DATA_STORE_CONTENT_VERSION);
    
    [self.applications removeAllObjects];
    for (NSDictionary *appDictionary in [dictionary objectForKey:@"apps"]) {
        [self.applications addObject:[[[MIGAApplicationInfo alloc] initWithContentsOfDictionary:appDictionary] autorelease]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MIGAMoreGamesDataStoreDidUpdateNotification object:self];
}


- (void)setApplicationsWithJSONString:(NSString *)json {
    id parsedJSON = [json JSONValue];
    
    if ([self validateContent:parsedJSON])
        [self setApplicationsWithDictionary:parsedJSON];
}


- (BOOL)setApplicationsWithContentsOfFile:(NSString *)filePath encoding:(NSStringEncoding)encoding error:(NSError **)error {
    return [self setApplicationsWithContentsOfURL:[NSURL fileURLWithPath:filePath] encoding:encoding error:error];
}


- (BOOL)setApplicationsWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)encoding error:(NSError **)error {
    NSString *json = [NSString stringWithContentsOfURL:url encoding:encoding error:error];
    
    if (!json)
        return NO;
    
    [self setApplicationsWithJSONString:json];
    
    return YES;
}


- (void)setApplicationsWithAsynchronousRequestToURL:(NSURL *)url {
    MIGADLog(@"Sending request for %@ ...", [url description]);
    [_request release];
    
    NSString *platformName = @"IPHONE";
#if MIGA_IOS_3_2_SUPPORTED
    if (([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)]) && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)) {
        platformName = @"IPAD";
    }
#endif
    
    NSDictionary *requestDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:1], @"version",
                                       [[NSBundle mainBundle] bundleIdentifier], @"package",
                                       [[UIDevice currentDevice] uniqueIdentifier], @"device_id",
                                       platformName, @"platform",
#ifdef DEBUG
                                       [NSNumber numberWithInt:1], @"test_mode",
#endif
                                       nil];
    
    NSString *json = [requestDictionary JSONRepresentation];
    NSDictionary *postDictionary = [NSDictionary dictionaryWithObject:json forKey:@"request"];
    
    _request = [[MIGAAsyncHttpRequest requestWithURL:url postDictionary:postDictionary delegate:self] retain];
    // If the delegate was unset during instantiation, we know there was
    // a failure in the interim.
    if (_request.delegate == nil) {
        [_request release];
        _request = nil;
    }
}


- (BOOL)setApplicationsWithDefaultContent {
    MIGAURL *url = [MIGAURL URLWithString:@"miga-bundle:///MIGAMoreGamesDefaultContent/content.json"];
    
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:[url path]];

    if (result) {
        MIGADLog(@"Using default content feed file found at path: %@", [url path]);
    }
    
    result = result && [self setApplicationsWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
    
    if (!result) {
        MIGADLog(@"Setting applications with default content failed.");
        _failed = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:MIGAMoreGamesDataStoreDidFailLoadingNotification object: self];
    }
    return result;
}


- (BOOL)writeToFile:(NSString *)filePath encoding:(NSStringEncoding)encoding error:(NSError **)error {
    NSMutableArray *appsArray = [[NSMutableArray alloc] initWithCapacity:[self.applications count]];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSUInteger batchCount = 0;
    
    for (MIGAApplicationInfo *app in self.applications) {
        
        [appsArray addObject:[app dictionaryValue]];
    
        batchCount++;
        
        if (batchCount >= MIGA_MORE_GAMES_DATA_STORE_WRITE_BATCH_SIZE) {
            [pool release];
            pool = [[NSAutoreleasePool alloc] init];
        }
    }
    [pool release];
    
    NSString *jsonString = [[NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:MIGA_MORE_GAMES_DATA_STORE_CONTENT_VERSION], @"version",
                             appsArray, @"apps",
                             nil] JSONRepresentation];
    [appsArray release];
    
    return [jsonString writeToFile:filePath atomically:YES encoding:encoding error:error];
}


- (void)update {
    if ((_request == nil) && (_requestedURL != nil)) {
        _failed = NO;
        [self setApplicationsWithAsynchronousRequestToURL:_requestedURL];
    }
}


#pragma mark -
#pragma mark AsyncHttpRequestDelegate Methods

- (void)asyncHttpRequest:(MIGAAsyncHttpRequest *)request didFinishWithContent:(NSData *)responseContent {
    if (request != _request)
        return;
    
    NSString *responseString = [[NSString alloc] initWithData:responseContent encoding:_request.receivedStringEncoding];
    [self setApplicationsWithJSONString:responseString];
    [responseString release];
    [_request release];
    _request = nil;
}


- (void)asyncHttpRequestDidFail:(MIGAAsyncHttpRequest *)request {
    [_request release];
    _request = nil;
    
    MIGADLog(@"MIGAMoreGamesDataStore: Asynchronous application JSON request failed. Will attempt to fall back to default content.");
    
    [self setApplicationsWithDefaultContent];
}


- (BOOL)validateContent:(id)contentObject {
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

- (void)setApplicationsWithAsynchronousRequestToURL:(NSURL *)url {
    MIGADLog(@"Attempting to obtain object for %@ from cache...", [url description]);
    
    BOOL objectIsExpired = NO;
    if ([_cacheManager cachedObjectExistsForURL:url isExpired:&objectIsExpired]) {
    
        if (!objectIsExpired) {
            MIGADLog(@"Cache hit for %@.", [url description]);
            NSDictionary *cachedDictionary = (NSDictionary *)[_cacheManager objectForURL:url];
            [self setApplicationsWithDictionary:cachedDictionary];
            
            return;
        }
        
        MIGADLog(@"Cached item for %@ is stale.  Will attempt to fetch.", [url description]);
    } else {
        MIGADLog(@"Cache miss for %@. Will attempt to fetch.", [url description]);
    }
    
    [super setApplicationsWithAsynchronousRequestToURL:url];
}


#pragma mark -
#pragma mark AsyncHttpRequestDelegate Methods

- (void)asyncHttpRequest:(MIGAAsyncHttpRequest *)request didFinishWithContent:(NSData *)responseContent {
    if (request != _request)
        return;
    NSString *responseString = [[NSString alloc] initWithData:responseContent encoding:_request.receivedStringEncoding];
    id parsedJSON = [responseString JSONValue];
    [responseString release];
    
    if ([self validateContent:parsedJSON]) {
        NSTimeInterval expireAt = [parsedJSON objectForKey:@"expire_at"] ? [[parsedJSON objectForKey:@"expire_at"] doubleValue] : 0;
        NSTimeInterval purgeAt = [parsedJSON objectForKey:@"purge_at"] ? [[parsedJSON objectForKey:@"purge_at"] doubleValue] : 0;
        MIGADLog(@"Caching parsed json for URL: %@.  Will expire at %f and purge at %f (or global values if global values are earlier).", [request.requestedURL description], expireAt, purgeAt);
        [_cacheManager setObject:parsedJSON forURL:request.requestedURL expireAt:expireAt purgeAt:purgeAt];
        [self setApplicationsWithDictionary:parsedJSON];
    } else {
        [self asyncHttpRequestDidFail:request];
    }

    [_request release];
    _request = nil;
}


- (void)asyncHttpRequestDidFail:(MIGAAsyncHttpRequest *)request {
    MIGADLog(@"Asynchronous application JSON request failed.  Attempting to obtain stale object from cache.");

    NSURL *url = request.requestedURL;

    NSDictionary *cachedDictionary = (NSDictionary *)[_cacheManager objectForURL:url];
    if (cachedDictionary) {
        MIGADLog(@"Stale cache hit for %@", [url description]);

        [_request release];
        _request = nil;

        [self setApplicationsWithDictionary:cachedDictionary];
        return;
    }

    MIGADLog(@"Stale cache miss for %@", [url description]);
    [super asyncHttpRequestDidFail:request];
}


@end