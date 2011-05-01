//
//  MIGAAsyncImageRequestManager.m
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/23/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "MIGALogging.h"
#import "MIGAAvailability.h"
#import "MIGAAsyncImageRequestManager.h"
#import "MIGAPersistentCacheManager.h"
#import "MIGAAsyncHttpRequest.h"

NSString * const MIGAAsyncImageRequestManagerImageDidChangeNotification = @"MIGAAsyncImageRequestManagerImageDidChange";
NSString * const MIGAAsyncImageRequestManagerImageIsUnavailableNotification = @"MIGAAsyncImageRequestManagerImageIsUnavailable";

NSString * const MIGAAsyncImageRequestManagerURLUserInfoKey = @"MIGAAsyncImageRequestManagerURL";
NSString * const MIGAAsyncImageRequestManagerImageUserInfoKey = @"MIGAAsyncImageRequestManagerImage";

static MIGAAsyncImageRequestManager *defaultManager = nil;

@interface MIGACacheBackedAsyncImageRequestManager : MIGAAsyncImageRequestManager
{
}

@end

#pragma mark -

@interface MIGAAsyncImageRequestManager ()

@property (nonatomic, retain) NSMutableDictionary *requests;
@property (nonatomic, retain) NSMutableDictionary *loadedImages;

-(void)drainImages;
-(UIImage *)loadedImageWithURL: (NSURL *)url;
-(void)addAysncHttpRequestForURL: (NSURL *)url;

-(void)postImageDidChangeNotificationForURL: (NSURL *)url image: (UIImage *)image;
-(void)postImageIsUnavailableNotificationForURL: (NSURL *)url;

-(void)handleUIApplicationDidReceiveMemoryWarningNotification: (NSNotification *)notification;
-(void)handleUIApplicationDidEnterBackgroundNotification: (NSNotification *)notification;
@end

#pragma mark -

@implementation MIGAAsyncImageRequestManager
#pragma mark -
#pragma mark Properties
@synthesize cacheManager;
@synthesize requests, loadedImages;

-(NSMutableDictionary *)requests;
{
	if (!requests) {
		requests = [[NSMutableDictionary alloc] initWithCapacity: 10];
	}
	
	return requests;
}

-(NSMutableDictionary *)loadedImages;
{
	if (!loadedImages) {
		loadedImages = [[NSMutableDictionary alloc] initWithCapacity: 10];
	}
	
	return loadedImages;
}

#pragma mark -
#pragma mark Class Methods

+(MIGAAsyncImageRequestManager *)defaultManager;
{
	if (!defaultManager) {
		defaultManager = [[MIGAAsyncImageRequestManager alloc] initWithCacheManager: [MIGAPersistentCacheManager defaultManager]];
	}
	
	return defaultManager;
}

#pragma mark -
#pragma mark Instance Methods

-(id)init;
{
	if ((self = [super init])) {
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver: self selector: @selector(handleUIApplicationDidReceiveMemoryWarningNotification:) name: UIApplicationDidReceiveMemoryWarningNotification object: nil];
		
#if MIGA_IOS_4_0_SUPPORTED
		BOOL supportsBackgrounding = (&UIApplicationDidEnterBackgroundNotification != NULL);
		if (supportsBackgrounding) {
			[center addObserver: self selector: @selector(handleUIApplicationDidEnterBackgroundNotification:) name: UIApplicationDidEnterBackgroundNotification object: nil];
		}
#endif
	}
	
	return self;
}

-(id)initWithCacheManager: (MIGAPersistentCacheManager *)aCacheManager;
{
	if ((self = [self init])) {
		cacheManager = [aCacheManager retain];
		if (cacheManager) {
			isa = [MIGACacheBackedAsyncImageRequestManager class];
		}
	}
	
	return self;
}

-(void)dealloc;
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[requests release];
	[loadedImages release];
	[cacheManager release];

	[super dealloc];
}

-(void)drainImages;
{
	MIGADLog(@"Draining loaded images cache.");
	self.loadedImages = nil;
}

-(UIImage *)requestImageWithURL: (NSURL *)url;
{
	UIImage *result = [self loadedImageWithURL: url];
	
	if (!result) {
		[self addAysncHttpRequestForURL: url];
	}
	
	return result;
}

-(UIImage *)loadedImageWithURL: (NSURL *)url;
{
	UIImage *result = [self.loadedImages objectForKey: [url absoluteString]];
	if (!result) {
		MIGADLog(@"Loaded image miss for URL: %@", url);
		if ([url isFileURL]) {
			result = [UIImage imageWithContentsOfFile: [url path]];
			if (result) {
				MIGADLog(@"File hit.  Adding to loadedImages.");
				[self.loadedImages setObject: result forKey: [url absoluteString]];
			} else {
				MIGADLog(@"File miss.");
			}
		}
	} else {
		MIGADLog(@"Loaded image hit for URL: %@", url);
	}
	
	return result;
}

-(void)addAysncHttpRequestForURL: (NSURL *)url;
{
	if (url == nil)
		return;
	
	if ([url isFileURL]) {
		MIGADLog(@"URL %@ is a file url.  Will not add request.", url);
		return;
	}
	
	MIGAAsyncHttpRequest *request = [self.requests objectForKey: [url absoluteString]];
	if (!request) {
		MIGADLog(@"Adding async http request for image with url: %@", url);
		request = [[MIGAAsyncHttpRequest requestWithURL: url delegate: self] retain];
		[self.requests setObject: request forKey: [url absoluteString]];
		[request release];
	} else {
		MIGADLog(@"Request for image with url %@ already exists.  Skipping.", url);
	}
}

-(void)postImageDidChangeNotificationForURL: (NSURL *)url image: (UIImage *)image;
{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
														url, MIGAAsyncImageRequestManagerURLUserInfoKey,
														image, MIGAAsyncImageRequestManagerImageUserInfoKey,
														nil];
	
	NSNotification *notification = [NSNotification notificationWithName: MIGAAsyncImageRequestManagerImageDidChangeNotification object: [url absoluteString] userInfo: userInfo];
	
	[[NSNotificationQueue defaultQueue] enqueueNotification: notification postingStyle: NSPostWhenIdle coalesceMask: NSNotificationNoCoalescing forModes: nil];
}

-(void)postImageIsUnavailableNotificationForURL: (NSURL *)url;
{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
														url, MIGAAsyncImageRequestManagerURLUserInfoKey,
														nil];
	
	NSNotification *notification = [NSNotification notificationWithName: MIGAAsyncImageRequestManagerImageIsUnavailableNotification object: [url absoluteString] userInfo: userInfo];
	
	[[NSNotificationQueue defaultQueue] enqueueNotification: notification postingStyle: NSPostWhenIdle coalesceMask: NSNotificationNoCoalescing forModes: nil];	
}

#pragma mark -
#pragma mark AsyncHttpRequestDelegate Methods

-(void)asyncHttpRequest:(MIGAAsyncHttpRequest *)request didFinishWithContent:(NSData *)responseContent;
{
	NSURL *url = [request.requestedURL retain];

	UIImage *image = [[UIImage alloc] initWithData: responseContent];
	if (image) {
		[self.loadedImages setObject: image forKey: [url absoluteString]];
		[self postImageDidChangeNotificationForURL: url image: image];
	} else {
		[self postImageIsUnavailableNotificationForURL: url];
	}
	
	[self.requests removeObjectForKey: [url absoluteString]];
	
	[image release];
	[url release];
}

-(void)asyncHttpRequestDidFail:(MIGAAsyncHttpRequest *)request;
{
	NSURL *url = [request.requestedURL retain];
	MIGADLog(@"Image request failed for URL: %@", url);
	[self.requests removeObjectForKey: [url absoluteString]];
	[self postImageIsUnavailableNotificationForURL: url];

	[url release];
}


#pragma mark -
#pragma mark Notification Handlers
-(void)handleUIApplicationDidReceiveMemoryWarningNotification: (NSNotification *)notification;
{
	[self drainImages];
}

-(void)handleUIApplicationDidEnterBackgroundNotification: (NSNotification *)notification;
{
	[self drainImages];
}

@end

#pragma mark -

@implementation MIGACacheBackedAsyncImageRequestManager

-(UIImage *)requestImageWithURL:(NSURL *)url;
{
	UIImage *result = [self loadedImageWithURL: url];
	
	if (!result) {
		if ([url isFileURL]) {
			MIGADLog(@"URL %@ is a file URL.  Will not attempt to obtain from cache.", url);
		} else {
			BOOL objectIsExpired = NO;
			if ([cacheManager cachedObjectExistsForURL: url isExpired: &objectIsExpired]) {
				MIGADLog(@"Cache hit for %@", url);
				// We want to return an image object immediately if at all possible,
				// so even if the object is stale, we return it and follow up
				// with a request.  A notification will be sent when an updated
				// image is available.
				result = [UIImage imageWithData: (NSData *)[cacheManager objectForURL: url]];
				if (result) {
					[self.loadedImages setObject: result forKey: [url absoluteString]];
				}

				if (objectIsExpired) {
					MIGADLog(@"Object is stale.  Will make request.");
					[self addAysncHttpRequestForURL: url];
				}
			} else {
				MIGADLog(@"Cache miss for %@", url);
			}
		}
	}
	
	if (!result) {
		[self addAysncHttpRequestForURL: url];
	}
	
	return result;
}

#pragma mark -
#pragma mark AsyncHttpRequestDelegate Methods

-(void)asyncHttpRequest:(MIGAAsyncHttpRequest *)request didFinishWithContent:(NSData *)responseContent;
{
	NSURL *url = [request.requestedURL retain];
	
	[super asyncHttpRequest: request didFinishWithContent: responseContent];
	
	if ((responseContent != nil) && ([responseContent length] > 0)) {
		MIGADLog(@"Caching image data for URL: %@", url);
		[cacheManager setObject: responseContent forURL: url];
	} else {
		MIGADLog(@"Response content for URL %@ is nil or empty. Will not cache.", url);
	}
	
	[url release];
}

@end

