//
//  MIGAAsyncImageView.h
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/16/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MIGAAsyncImageRequestManager;

@interface MIGAAsyncImageView : UIView {
	@private
	NSURL *imageURL;
	CGFloat imageContentScale;
	CGSize nativeImageSize;
	
	MIGAAsyncImageRequestManager *requestManager;
	
	UIActivityIndicatorView *activityIndicatorView;
}

@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, assign) CGFloat imageContentScale;
@property (nonatomic, assign) CGSize nativeImageSize;

-(id)initWithFrame:(CGRect)frame requestManager: (MIGAAsyncImageRequestManager *)requestManager;

@end
