//
//  MIGAAsyncHttpRequest.m
//  MIGAUtils
//
//  Created by impact on 2/26/10.
//  Adapted for MIGA by Darryl H. Thomas on 7/23/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIGAAvailability.h"
#import "Reachability.h"
#import "MIGALogging.h"
#import "MIGAAsyncHttpRequest.h"
#import "NSString+migaURLEncodedString.h"

#define ASYNC_HTTP_REQUEST_DEFAULT_TIMEOUT_INTERVAL 10.0

// Because there is no safe way to determine the availability of blocks at runtime,
// we require explicit opt-in by the developer.  This is an indication that the developer
// has fulfilled his part of the contract by adding '-weak_library /usr/lib/libSystem.B.dylib'
// to the linking flags or is willing to accept the consequences otherwise.
// Developers can squelch the warning without enabling background task completion by
// defining MIGA_ASYNC_HTTP_REQUEST_DO_NOT_USE_BLOCKS.
#if MIGA_IOS_4_0_SUPPORTED
#if MIGA_IOS_PRE_3_2_SUPPORTED
#ifndef MIGA_ASYNC_HTTP_REQUEST_USE_BLOCKS
#ifndef MIGA_ASYNC_HTTP_REQUEST_DO_NOT_USE_BLOCKS
#warning "It appears you are including support for iOS4.  MIGAAsyncHttpRequest supports background task completion, but this functionality must be explicitly enabled to avoid crashes on pre-3.2 devices."
#warning "To enable background task completion for MIGAAsyncHttpRequest, make sure your linker flags [OTHER_LDFLAGS] include '-weak_library /usr/lib/libSystem.B.dylib' if your target OS version is less than 3.2 and add MIGA_ASYNC_HTTP_REQUEST_USE_BLOCKS to your pre-processor macros [GCC_PREPROCESSOR_DEFINITIONS].  If you do not want to enable background task completion and want these warnings to go away, add MIGA_ASYNC_HTTP_REQUEST_DO_NOT_USE_BLOCKS to your pre-processor macros."
#endif
#define MIGA_ASYNC_HTTP_REQUEST_BLOCKS_USE_ALLOWED 0
#else
#define MIGA_ASYNC_HTTP_REQUEST_BLOCKS_USE_ALLOWED 1
#endif
#else
#define MIGA_ASYNC_HTTP_REQUEST_BLOCKS_USE_ALLOWED 1
#endif
#else
#define MIGA_ASYNC_HTTP_REQUEST_BLOCKS_USE_ALLOWED 0
#endif


@interface MIGAAsyncHttpRequest ()

@property (nonatomic, retain, readonly) NSMutableData *receivedData;
@property (nonatomic, retain, readwrite) NSURL *requestedURL;
@property (nonatomic, retain, readwrite) NSString *receivedMIMEContentType;
@property (nonatomic, assign, readwrite) NSStringEncoding receivedStringEncoding;

-(void)handleFailure;
-(void)handleSuccess;

-(void)cleanupConnection;

-(NSData *)encodePostDataFromPostDictionaryAsURLEncodedWWWForm;

@end

@implementation MIGAAsyncHttpRequest

#pragma mark -
#pragma mark Properties

@synthesize delegate;
@synthesize timeoutInterval;
@synthesize requestedURL;
@synthesize receivedMIMEContentType;
@synthesize receivedStringEncoding;
@synthesize postDictionary;

-(NSMutableData *)receivedData;
{
	if (!receivedData) {
		receivedData = [[NSMutableData alloc] init];
	}
	
	return receivedData;
}

#pragma mark -
#pragma mark Class Methods

+(MIGAAsyncHttpRequest *)requestWithURL: (NSURL *)url delegate: (id<MIGAAsyncHttpRequestDelegate>)aDelegate;
{
	MIGAAsyncHttpRequest *request = [[MIGAAsyncHttpRequest alloc] init];
	request.delegate = aDelegate;
	[request startRequestWithURL: url];
	
	return [request autorelease];
}

+(MIGAAsyncHttpRequest *)requestWithURLString:(NSString*)URLString delegate:(id<MIGAAsyncHttpRequestDelegate>)aDelegate;
{
	MIGAAsyncHttpRequest *request = [[MIGAAsyncHttpRequest alloc] init];
	request.delegate = aDelegate;
	[request startRequestWithURLString: URLString];
	
	return [request autorelease];
}

+(MIGAAsyncHttpRequest *)requestWithURL: (NSURL *)url postDictionary: (NSDictionary *)postValuesAndNames delegate: (id<MIGAAsyncHttpRequestDelegate>)aDelegate;
{
	MIGAAsyncHttpRequest *request = [[MIGAAsyncHttpRequest alloc] init];
	request.delegate = aDelegate;
	request.postDictionary = postValuesAndNames;
	
	[request startRequestWithURL: url];
	
	return [request autorelease];
}

#pragma mark -
#pragma mark Instance Methods

-(id)init;
{
	if ((self = [super init])) {
		self.timeoutInterval = ASYNC_HTTP_REQUEST_DEFAULT_TIMEOUT_INTERVAL;
		backgroundTaskSupported = NO;
		backgroundTaskIdentifier = 0;
		
#if MIGA_ASYNC_HTTP_REQUEST_BLOCKS_USE_ALLOWED
		backgroundTaskSupported = [[UIApplication sharedApplication] respondsToSelector: @selector(backgroundTimeRemaining)];
		
		if (backgroundTaskSupported) {
			backgroundTaskSupported = [[UIApplication sharedApplication] respondsToSelector: @selector(beginBackgroundTaskWithExpirationHandler:)] && ((&UIBackgroundTaskInvalid != NULL));
		}
		
		if (backgroundTaskSupported) {
			backgroundTaskIdentifier = UIBackgroundTaskInvalid;
		}
#endif
	}
	
	return self;
}

-(void)dealloc;
{
#if MIGA_ASYNC_HTTP_REQUEST_BLOCKS_USE_ALLOWED
	if (backgroundTaskSupported && (backgroundTaskIdentifier != UIBackgroundTaskInvalid)) {
		[[UIApplication sharedApplication] endBackgroundTask: backgroundTaskIdentifier];
	}
#endif
	[receivedData release];
	[receivedMIMEContentType release];
	[requestedURL release];
	[postDictionary release];
	[delegate release];
	
	[super dealloc];
}

-(void)handleFailure;
{
	if (delegate && [delegate respondsToSelector: @selector(asyncHttpRequestDidFail:)]) {
		[delegate asyncHttpRequestDidFail: self];
	}
	
	[self cleanupConnection];
}

-(void)handleSuccess;
{
	if (delegate && [delegate respondsToSelector: @selector(asyncHttpRequest:didFinishWithContent:)]) {
		[delegate asyncHttpRequest: self didFinishWithContent: (NSData *)self.receivedData];
	}

	[self cleanupConnection];
}

-(void)cleanupConnection;
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	
	if (connection != nil) {
		[connection cancel];
		[connection release];
		connection = nil;
	}
	
	if (receivedData != nil) {
		[receivedData release];
		receivedData = nil;
	}
	
	self.delegate = nil;

#if MIGA_ASYNC_HTTP_REQUEST_BLOCKS_USE_ALLOWED
	if (backgroundTaskSupported && (backgroundTaskIdentifier != UIBackgroundTaskInvalid)) {
		[[UIApplication sharedApplication] endBackgroundTask: backgroundTaskIdentifier];
		backgroundTaskIdentifier = UIBackgroundTaskInvalid;
	}
#endif
}

-(void)startRequestWithURL: (NSURL *)url;
{
	assert(connection == nil);
	
	self.requestedURL = url;
	
#if MIGA_ASYNC_HTTP_REQUEST_BLOCKS_USE_ALLOWED
	if (backgroundTaskSupported) {
		NSThread *targetThread = [NSThread currentThread];
		backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
			[self performSelector: @selector(handleFailure) onThread: targetThread withObject: nil waitUntilDone: YES];
		}];
	}
#endif

	Reachability *urlReachability = [Reachability reachabilityWithHostName: [url host]];
	NetworkStatus status = [urlReachability currentReachabilityStatus];
	if (status == NotReachable) {
		[self handleFailure];
		return;
	}
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
	
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: self.timeoutInterval];
	
	if (postDictionary) {
		[request setHTTPMethod: @"POST"];
		
		NSString *characterSet = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));

		[request setValue: [NSString stringWithFormat: @"application/x-www-form-urlencoded; charset=%@", characterSet] forHTTPHeaderField: @"Content-type"];
		[request setHTTPBody: [self encodePostDataFromPostDictionaryAsURLEncodedWWWForm]];
	}
	
	connection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
	if (!connection) {
		[self handleFailure];
	}
}

-(void)startRequestWithURLString:(NSString *)URLString;
{
	
	NSString *escapedURLString = [URLString stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
	NSURL *url = [NSURL URLWithString: escapedURLString];
	
	[self startRequestWithURL: url];
}

-(void)cancel;
{
	[self cleanupConnection];
}

-(NSData *)encodePostDataFromPostDictionaryAsURLEncodedWWWForm;
{
	NSMutableData *result = [[NSMutableData alloc] initWithCapacity: 2048];
	NSInteger i = 0;
	NSInteger lastIndex = [self.postDictionary count] - 1;
	for (NSString *key in [self.postDictionary allKeys]) {
		NSString *urlEncodedName = [key migaURLEncodedString];
		NSString *urlEncodedValue = [(NSString *)[self.postDictionary objectForKey: key] migaURLEncodedString];
		NSData *nameValuePair = [[NSString stringWithFormat: @"%@=%@%@", urlEncodedName, urlEncodedValue, (i < lastIndex) ? @"&" : @""] dataUsingEncoding: NSUTF8StringEncoding];
		
		[result appendData: nameValuePair];
		
		i++;
	}
	
	return [result autorelease];
}


#pragma mark -
#pragma mark NSURLConnection Delegate Methods

-(void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response;
{
	assert(connection == aConnection);
	
	if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
		NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
		if (statusCode >= 404) {
			MIGADLog(@"Status code is %d.  Treating as failure.", statusCode);
			[self handleFailure];
			return;
		}
	}
	
	self.receivedMIMEContentType = [response MIMEType];
	NSString *responseTextEncodingName = [response textEncodingName];
	if (responseTextEncodingName) {
		MIGADLog(@"Response text encoding is %@", responseTextEncodingName);
		CFStringEncoding cfEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)responseTextEncodingName);
		if (cfEncoding != kCFStringEncodingInvalidId) {
			self.receivedStringEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding);
		}
	} else {
		self.receivedStringEncoding = NSUTF8StringEncoding;
	}
	
	[self.receivedData setLength:0];
}

-(void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data;
{
	assert(connection == aConnection);
	
	[self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error;
{
	assert(connection == aConnection);

	[self handleFailure];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)aConnection;
{
	assert(connection == aConnection);

	[self handleSuccess];
}


@end
