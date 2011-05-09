//
//  MIGAURL.m
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/13/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "MIGAURL.h"


@implementation MIGAURL

- (id)initWithString:(NSString *)URLString relativeToURL:(NSURL *)baseURL {
	if ((self = [super initWithString:URLString relativeToURL:baseURL])) {
		if ([[self scheme] isEqualToString:@"miga-bundle"]) {			
			NSBundle *bundle;
			if ([self host] == nil) {
				bundle = [NSBundle mainBundle];
			} else {
				bundle = [NSBundle bundleWithIdentifier:[self host]];
			}
			
			if (bundle == nil) {
				[self release];
				return nil;
			}
			
			NSString *filePath = [[bundle bundlePath] stringByAppendingPathComponent:[self path]];
			
			[self release];
			self = [[MIGAURL alloc] initFileURLWithPath:filePath];
		}
	}
	
	return self;
}

@end
