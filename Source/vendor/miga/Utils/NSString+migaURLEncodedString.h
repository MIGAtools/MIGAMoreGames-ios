//
//  NSString+migaURLEncodedString.h
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/16/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (migaURLEncodedString)

-(NSString *)migaURLEncodedString;
-(NSString *)migaURLEncodedStringWithStringEncoding: (NSStringEncoding)encoding;

@end
