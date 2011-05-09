//
//  MIGAGradientView.m
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/7/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "MIGAGradientView.h"


@implementation MIGAGradientView
@dynamic layer;

+ (Class)layerClass {
    return [CAGradientLayer class];
}


- (void)setColors:(NSArray *)aColors {
    [self.layer setColors:aColors];
}


- (NSArray *)colors {
    return [self.layer colors];
}


- (void)setLocations:(NSArray *)aLocations {
    [self.layer setLocations:aLocations];
}


- (NSArray *)locations {
    return [self.layer locations];
}


- (void)setStartPoint:(CGPoint)aPoint {
    [self.layer setStartPoint:aPoint];
}


- (CGPoint)startPoint {
    return [self.layer startPoint];
}


- (void)setEndPoint:(CGPoint)aPoint {
    [self.layer setEndPoint:aPoint];
}


- (CGPoint)endPoint {
    return [self.layer endPoint];
}


- (void)setType:(NSString *)aType {
    [self.layer setType:aType];
}


- (NSString *)type {
    return [self.layer type];
}


@end
