//
//  MIGAMoreGamesActivityReportManager.h
//  MIGAMoreGames
//
//  Created by Darryl H. Thomas on 8/24/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIGAAsyncHttpRequest.h"

@interface MIGAMoreGamesActivityReportManager : NSObject<MIGAAsyncHttpRequestDelegate> {
	@private
	BOOL enabled;
	BOOL initialized;
	
	NSMutableArray *actions;
	NSArray *pendingSubmissionActions;
	MIGAAsyncHttpRequest *request;
}

@property (nonatomic, assign) BOOL enabled;

+(MIGAMoreGamesActivityReportManager *)sharedManager;

-(void)logSessionStartWithDate: (NSDate *)date;
-(void)logPresentationWithDate: (NSDate *)date;
-(void)logDismissalWithDate: (NSDate *)date;
-(void)logClickWithDate: (NSDate *)date contentId: (NSUInteger)contentId;
-(void)logImpressionWithDate: (NSDate *)date contentId: (NSUInteger)contentId duration: (NSTimeInterval)duration;
-(void)submitActivity;

@end
