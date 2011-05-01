//
//  MIGAAsyncImageRequestManager.h
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/23/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIGAAsyncHttpRequest.h"

extern NSString * const MIGAAsyncImageRequestManagerImageDidChangeNotification;
extern NSString * const MIGAAsyncImageRequestManagerImageIsUnavailableNotification;

extern NSString * const MIGAAsyncImageRequestManagerURLUserInfoKey;
extern NSString * const MIGAAsyncImageRequestManagerImageUserInfoKey;

@class MIGAPersistentCacheManager;

@interface MIGAAsyncImageRequestManager : NSObject<MIGAAsyncHttpRequestDelegate> {
	@protected
	NSMutableDictionary *requests;
	NSMutableDictionary *loadedImages;
	MIGAPersistentCacheManager *cacheManager;
}

@property (nonatomic, retain, readonly) MIGAPersistentCacheManager *cacheManager;

+(MIGAAsyncImageRequestManager *)defaultManager;

-(id)initWithCacheManager: (MIGAPersistentCacheManager *)cacheManager;

-(UIImage *)requestImageWithURL: (NSURL *)url;

@end
