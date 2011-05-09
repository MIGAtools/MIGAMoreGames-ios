//
//  NSString+migaURLEncodedString.m
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/16/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "NSString+migaURLEncodedString.h"


@implementation NSString (migaURLEncodedString)

- (NSString *)migaURLEncodedString {
    return [self migaURLEncodedStringWithStringEncoding:NSUTF8StringEncoding];
}


- (NSString *)migaURLEncodedStringWithStringEncoding:(NSStringEncoding)encoding {
    NSString *result = [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(encoding)) autorelease];
    
    if (!result) {
        return @"";
    }
    
    return result;
}


@end
