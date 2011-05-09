//
//  UIColor+MIGAExtensions.m
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/15/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "UIColor+MIGAExtensions.h"

@implementation UIColor (MIGAExtensions)

+ (UIColor *)migaColorWithHexString:(NSString *)hexString {
	return [UIColor migaColorWithHexString:hexString ignoreAlphaComponent:NO];
}


+ (UIColor *)migaColorWithHexString:(NSString *)hexString ignoreAlphaComponent:(BOOL)ignoreAlpha {
	NSString *cleanedString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
	
	if ([cleanedString hasPrefix:@"#"]) {
		cleanedString = [cleanedString substringFromIndex:1];
	}
	
	NSInteger stringLength = [cleanedString length];
	if (stringLength < 6)
		return nil;
	
	NSRange range = NSMakeRange(0, 2);
	NSString *redString = [cleanedString substringWithRange:range];
	
	range.location = 2;
	NSString *greenString = [cleanedString substringWithRange:range];
	
	range.location = 4;
	NSString *blueString = [cleanedString substringWithRange:range];
	
	NSString *alphaString;
	if ([cleanedString length] >= 8) {
		range.location = 6;
		alphaString = [cleanedString substringWithRange:range];
	} else {
		ignoreAlpha = YES;
		alphaString = @"";
	}

	
	NSUInteger redInt, greenInt, blueInt, alphaInt;
	CGFloat redFloat, greenFloat, blueFloat, alphaFloat;
	
	[[NSScanner scannerWithString: redString] scanHexInt:&redInt];
	[[NSScanner scannerWithString: greenString] scanHexInt:&greenInt];
	[[NSScanner scannerWithString: blueString] scanHexInt:&blueInt];
	[[NSScanner scannerWithString: alphaString] scanHexInt:&alphaInt];

	redFloat = ((CGFloat)redInt / 255.0f);
	greenFloat = ((CGFloat)greenInt / 255.0f);
	blueFloat = ((CGFloat)blueInt / 255.0f);
	alphaFloat = ignoreAlpha ? 1.0f : ((CGFloat)alphaInt / 255.0f);
	
	return [UIColor colorWithRed:redFloat green:greenFloat blue:blueFloat alpha:alphaFloat];
}


- (NSString *)migaHexString {
	CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
	
	if (!((colorSpaceModel == kCGColorSpaceModelRGB) || (colorSpaceModel == kCGColorSpaceModelMonochrome)))
		return nil;
	
	const CGFloat *components = CGColorGetComponents([self CGColor]);
	int red, green, blue, alpha;
	
	if (colorSpaceModel == kCGColorSpaceModelMonochrome) {
		red = green = blue = (int)(components[0] * 255);
		alpha = (int)(components[1] * 255);
	} else {
		red = (int)(components[0] * 255);
		green = (int)(components[1] * 255);
		blue = (int)(components[2] * 255);
		alpha = (int)(components[3] * 255);
	}
	
	NSString *result = [NSString stringWithFormat:@"#%02X%02X%02X%02X", red, green, blue, alpha];
	
	return result;
}


@end
