//
//  UIColor+MIGAExtensions.h
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/15/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIColor (MIGAExtensions)

+(UIColor *)migaColorWithHexString: (NSString *)hexString;
+(UIColor *)migaColorWithHexString: (NSString *)hexString ignoreAlphaComponent: (BOOL)ignoreAlpha;

-(NSString *)migaHexString;

@end
