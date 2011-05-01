//
//  MIGAImpressionTimer.h
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/24/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MIGAImpressionTimer : NSObject {
	@protected
	BOOL running;
	NSTimeInterval tickInterval;
	NSTimeInterval elapsedTime;
	
	NSUInteger contentId;
	
	NSDate *lastResetDate;
	NSDate *referenceDate;
	NSTimer *timer;
}

@property (assign, readonly, getter=isRunning) BOOL running;
@property (nonatomic, assign) NSTimeInterval tickInterval;
@property (nonatomic, assign) NSTimeInterval elapsedTime;
@property (nonatomic, assign) NSUInteger contentId;
@property (nonatomic, retain, readonly) NSDate *lastResetDate;

-(id)initWithElapsedTime: (NSTimeInterval)elapsedTime;
-(id)initWithElapsedTime: (NSTimeInterval)elapsedTime tickInterval: (NSTimeInterval)tickInterval;

-(void)start;
-(void)stop;
-(void)reset;

-(NSNumber *)numberValue;

@end
