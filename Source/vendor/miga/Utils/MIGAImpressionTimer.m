//
//  MIGAImpressionTimer.m
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/24/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "MIGAImpressionTimer.h"

@interface MIGAImpressionTimer ()

@property (nonatomic,retain,readwrite) NSDate *lastResetDate;
@property (nonatomic,retain) NSDate *referenceDate;

- (void)timerFired;

@end

@implementation MIGAImpressionTimer
@synthesize running, tickInterval, elapsedTime, contentId, lastResetDate;
@synthesize referenceDate;

- (id)init {
    return [self initWithElapsedTime:0 tickInterval:1.0];
}


- (id)initWithElapsedTime:(NSTimeInterval)aElapsedTime {
    return [self initWithElapsedTime:aElapsedTime tickInterval:1.0];
}


- (id)initWithElapsedTime:(NSTimeInterval)aElapsedTime tickInterval:(NSTimeInterval)aTickInterval {
    if ((self = [super init])) {
        contentId = 0;
        running = NO;
        self.tickInterval = aTickInterval;
        referenceDate = lastResetDate = nil;		
        self.elapsedTime = aElapsedTime;
        
        if (aElapsedTime == 0) {
            [self reset];
        }
    }
    
    return self;
}


- (void)dealloc {
    [referenceDate release];
    [lastResetDate release];
    
    [super dealloc];
}


- (void)start {
    if (running)
        [self stop];
    
    self.referenceDate = [NSDate dateWithTimeIntervalSinceNow:-(self.elapsedTime)];
    timer = [NSTimer scheduledTimerWithTimeInterval:self.tickInterval target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    running = YES;
}


- (void)stop {
    [timer invalidate];
    timer = nil;
    
    running = NO;
}


- (void)reset {
    BOOL wasRunning = running;
    [self stop];
    
    self.elapsedTime = 0;
    self.referenceDate = self.lastResetDate = [NSDate dateWithTimeIntervalSinceNow:0];
    
    if (wasRunning) {
        [self start];
    }
}


- (void)timerFired {
    if (!running)
        return;
    
    self.elapsedTime = -([self.referenceDate timeIntervalSinceNow]);
}


- (NSNumber *)numberValue {
    return [NSNumber numberWithDouble:self.elapsedTime];
}


@end
