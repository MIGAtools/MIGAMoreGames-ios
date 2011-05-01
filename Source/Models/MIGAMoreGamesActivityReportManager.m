//
//  MIGAMoreGamesActivityReportManager.m
//  MIGAMoreGames
//
//  Created by Darryl H. Thomas on 8/24/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "MIGAMoreGamesActivityReportManager.h"
#import "MIGAAvailability.h"
#import "MIGALogging.h"
#import "MIGAConf.h"
#import "JSON.h"

static MIGAMoreGamesActivityReportManager *sharedManager = nil;

NSString * const kMIGAMoreGamesActivityReportManagerActionTimestampKey = @"timestamp";
NSString * const kMIGAMoreGamesActivityReportManagerActionContentIdKey = @"content_id";
NSString * const kMIGAMoreGamesActivityReportManagerActionTypeKey = @"action_type";
NSString * const kMIGAMoreGamesActivityReportManagerActionDurationKey = @"duration";

NSString * const kMIGAMoreGamesActivityReportManagerSessionStartActionType = @"session_start";
NSString * const kMIGAMoreGamesActivityReportManagerPresentationActionType = @"presentation";
NSString * const kMIGAMoreGamesActivityReportManagerDismissalActionType = @"dismissal";
NSString * const kMIGAMoreGamesActivityReportManagerImpressionActionType = @"impression";
NSString * const kMIGAMoreGamesActivityReportManagerClickActionType = @"click";

@interface MIGAMoreGamesActivityReportManager ()

-(void)logActionWithDictionary: (NSDictionary *)action;

@end

@implementation MIGAMoreGamesActivityReportManager

#pragma mark -
#pragma mark Properties
@synthesize enabled;

-(void)setEnabled:(BOOL)value;
{
	BOOL wasAlreadyEnabled = enabled;	
	enabled = value;
	
	if (!wasAlreadyEnabled) {
		[self logSessionStartWithDate: [NSDate date]];
	}
}

#pragma mark -
#pragma mark Instance Methods

-(id)init;
{
	@synchronized(self)
	{
		if (initialized)
			return self;
		
		if ((self = [super init])) {
			enabled = NO;
			actions = [[NSMutableArray alloc] initWithCapacity: 50];
			
			initialized = YES;
		}
		
		return self;
	}
}

-(void)logActionWithDictionary: (NSDictionary *)action;
{
	MIGADLog(@"%@", action);
	
	if (!enabled)
		return;
	
	[actions addObject: action];
}

-(void)logSessionStartWithDate: (NSDate *)date;
{
	NSDictionary *action = [NSDictionary dictionaryWithObjectsAndKeys:
													kMIGAMoreGamesActivityReportManagerSessionStartActionType, kMIGAMoreGamesActivityReportManagerActionTypeKey,
													[NSNumber numberWithInt: (int)floor([date timeIntervalSince1970])], kMIGAMoreGamesActivityReportManagerActionTimestampKey,
													nil];
	
	[self logActionWithDictionary: action];	
}

-(void)logPresentationWithDate: (NSDate *)date;
{
	NSDictionary *action = [NSDictionary dictionaryWithObjectsAndKeys:
													kMIGAMoreGamesActivityReportManagerPresentationActionType, kMIGAMoreGamesActivityReportManagerActionTypeKey,
													[NSNumber numberWithInt: (int)floor([date timeIntervalSince1970])], kMIGAMoreGamesActivityReportManagerActionTimestampKey,
													nil];
	
	[self logActionWithDictionary: action];
}

-(void)logDismissalWithDate: (NSDate *)date;
{
	NSDictionary *action = [NSDictionary dictionaryWithObjectsAndKeys:
													kMIGAMoreGamesActivityReportManagerDismissalActionType, kMIGAMoreGamesActivityReportManagerActionTypeKey,
													[NSNumber numberWithInt: (int)floor([date timeIntervalSince1970])], kMIGAMoreGamesActivityReportManagerActionTimestampKey,
													nil];
	
	[self logActionWithDictionary: action];
}

-(void)logClickWithDate: (NSDate *)date contentId: (NSUInteger)contentId;
{
	NSDictionary *action = [NSDictionary dictionaryWithObjectsAndKeys:
													kMIGAMoreGamesActivityReportManagerClickActionType, kMIGAMoreGamesActivityReportManagerActionTypeKey,
													[NSNumber numberWithInt: (int)floor([date timeIntervalSince1970])], kMIGAMoreGamesActivityReportManagerActionTimestampKey,
													[NSNumber numberWithUnsignedInt: contentId], kMIGAMoreGamesActivityReportManagerActionContentIdKey,
													nil];
	
	[self logActionWithDictionary: action];
}

-(void)logImpressionWithDate: (NSDate *)date contentId: (NSUInteger)contentId duration: (NSTimeInterval)duration;
{
	NSDictionary *action = [NSDictionary dictionaryWithObjectsAndKeys:
													kMIGAMoreGamesActivityReportManagerImpressionActionType, kMIGAMoreGamesActivityReportManagerActionTypeKey,
													[NSNumber numberWithInt: (int)floor([date timeIntervalSince1970])], kMIGAMoreGamesActivityReportManagerActionTimestampKey,
													[NSNumber numberWithUnsignedInt: contentId], kMIGAMoreGamesActivityReportManagerActionContentIdKey,
													[NSNumber numberWithInt: (int)floor(duration)], kMIGAMoreGamesActivityReportManagerActionDurationKey,
													nil];
	
	[self logActionWithDictionary: action];
}

-(void)submitActivity;
{
	if ((!enabled) || (request) || ([actions count] == 0))
		return;

	NSString *reportURLString = [NSString stringWithFormat: @"%@%@", DEFAULT_MIGA_HOST_BASE, DEFAULT_MIGA_MORE_GAMES_REPORTING_PATH];
	NSURL *reportURL = [NSURL URLWithString: reportURLString];

	
	NSString *platformName = @"IPHONE";
#if MIGA_IOS_3_2_SUPPORTED
	if (([[UIDevice currentDevice] respondsToSelector: @selector(userInterfaceIdiom)]) && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)) {
		platformName = @"IPAD";
	}
#endif
	pendingSubmissionActions = [actions copy];
	[actions removeAllObjects];
	NSDictionary *requestDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
																		 [NSNumber numberWithInt: 1], @"version",
																		 [[NSBundle mainBundle] bundleIdentifier], @"package",
																		 [[UIDevice currentDevice] uniqueIdentifier], @"device_id",
																		 platformName, @"platform",
#ifdef DEBUG
																		 [NSNumber numberWithInt: 1], @"test_mode",
#endif
																		 pendingSubmissionActions, @"actions",
																		 nil];
	
	NSString *json = [requestDictionary JSONRepresentation];
	MIGADLog(@"%@", json);
	NSDictionary *postDictionary = [NSDictionary dictionaryWithObject: json forKey: @"request"];
	
	MIGADLog(@"Sending request.");
	request = [[MIGAAsyncHttpRequest requestWithURL: reportURL postDictionary: postDictionary delegate: self] retain];
	// If the delegate was unset during instantiation, we know there
	// a failure in the interim.
	if (request.delegate == nil) {
		[request release];
		request = nil;
		[actions addObjectsFromArray: pendingSubmissionActions];
		[pendingSubmissionActions release];
		pendingSubmissionActions = nil;
	}
	
}

#pragma mark -
#pragma mark MIGAAsyncHttpRequestDelegate Methods

-(void)asyncHttpRequest:(MIGAAsyncHttpRequest *)aRequest didFinishWithContent:(NSData *)responseContent;
{
	NSURL *url = [request.requestedURL retain];
	MIGADLog(@"Request succeeded for URL: %@", url);
	MIGADLog(@"%@", [[[NSString alloc] initWithData: responseContent encoding: request.receivedStringEncoding] autorelease]);
	[request release];
	request = nil;
	[url release];

	[pendingSubmissionActions release];
	pendingSubmissionActions = nil;
}

-(void)asyncHttpRequestDidFail:(MIGAAsyncHttpRequest *)aRequest;
{
	NSURL *url = [request.requestedURL retain];
	MIGADLog(@"Request failed for URL: %@", url);
	[request release];
	request = nil;
	[url release];

	[actions addObjectsFromArray: pendingSubmissionActions];
	[pendingSubmissionActions release];
	pendingSubmissionActions = nil;
}


#pragma mark -
#pragma mark Singleton Implementation

+(MIGAMoreGamesActivityReportManager *)sharedManager;
{
	@synchronized(self)
	{
		if (sharedManager == nil) {
			sharedManager = [[MIGAMoreGamesActivityReportManager alloc] init];
		}
	}
	
	return sharedManager;
}

+(id)allocWithZone: (NSZone *)zone;
{
	@synchronized(self)
	{
		if (sharedManager == nil) {
			sharedManager = [super allocWithZone: zone];
			return sharedManager;
		}
	}
	
	return nil;
}

-(id)copyWithZone: (NSZone *)zone;
{
	return self;
}

-(id)retain;
{
	return self;
}

-(unsigned)retainCount;
{
	return UINT_MAX;
}

-(void)release;
{
	return;
}

-(id)autorelease;
{
	return self;
}

@end
