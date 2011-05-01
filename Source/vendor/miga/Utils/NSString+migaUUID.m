//
//  NSString+migaUUID.m
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 7/27/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "NSString+migaUUID.h"


@implementation NSString (migaUUID)

+(NSString *)migaUUIDString;
{
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
	
	return [(NSString *)uuidString autorelease];
}

@end
