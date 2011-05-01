//
//  MIGAAsyncImageView.m
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/16/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "MIGAAsyncImageView.h"
#import "MIGAAvailability.h"
#import "MIGALogging.h"
#import "MIGAAsyncImageRequestManager.h"
#import <QuartzCore/QuartzCore.h>

@interface MIGAAsyncImageView ()

@property (nonatomic, retain) MIGAAsyncImageRequestManager *requestManager;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

-(void)removeActivityIndicatorView;
-(void)setLayerContentWithImage: (UIImage *)image;
-(void)setLayerContentWithMissingImage;
-(void)handleMIGAAsyncImageRequestManagerImageDidChangeNotification: (NSNotification *)notification;
-(void)handleMIGAAsyncImageRequestManagerImageIsUnavailableNotification: (NSNotification *)notification;

@end

#pragma mark -

@implementation MIGAAsyncImageView

#pragma mark -
#pragma mark Properties

@synthesize requestManager;
@synthesize activityIndicatorView;
@synthesize imageURL;
@synthesize imageContentScale;
@synthesize nativeImageSize;

-(void)setImageURL:(NSURL *)url;
{
	if (url == imageURL)
		return;
	
	[url retain];
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
			
	if (url != nil) {
		[notificationCenter addObserver: self selector: @selector(handleMIGAAsyncImageRequestManagerImageDidChangeNotification:) name: MIGAAsyncImageRequestManagerImageDidChangeNotification object: nil];
		[notificationCenter addObserver: self selector: @selector(handleMIGAAsyncImageRequestManagerImageIsUnavailableNotification:) name: MIGAAsyncImageRequestManagerImageIsUnavailableNotification object: nil];
		
		[imageURL release];
		imageURL = url;
		
		UIImage *image = [self.requestManager requestImageWithURL: imageURL];
		if ((image == nil) && ([url isFileURL])) {
			[self setLayerContentWithMissingImage];
		} else {
			[self setLayerContentWithImage: image];
		}
	} else {
		[imageURL release];
		imageURL = nil;
		[self setLayerContentWithMissingImage];
	}
}

-(UIActivityIndicatorView *)activityIndicatorView;
{
	if (!activityIndicatorView) {
		activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
		activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
		activityIndicatorView.hidesWhenStopped = YES;
		[activityIndicatorView stopAnimating];
		[self addSubview: activityIndicatorView];
	}
	
	return activityIndicatorView;
}

#pragma mark -
#pragma mark Instance Methods

-(id)initWithFrame:(CGRect)aFrame requestManager:(MIGAAsyncImageRequestManager *)aRequestManager;
{
	if ((self = [super initWithFrame: aFrame])) {
		self.requestManager = aRequestManager;
		self.imageContentScale = 1.0;
		self.nativeImageSize = aFrame.size;
		[self setLayerContentWithMissingImage];
	}
	
	return self;
}

-(id)initWithFrame:(CGRect)aFrame;
{
	return [self initWithFrame: aFrame requestManager: [MIGAAsyncImageRequestManager defaultManager]];
}

-(void)dealloc;
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[imageURL release];
	[requestManager release];
	[activityIndicatorView release];
	
	[super dealloc];
}

-(void)removeActivityIndicatorView;
{
	if (!activityIndicatorView)
		return;
	
	[activityIndicatorView removeFromSuperview];
	[activityIndicatorView release];
	activityIndicatorView = nil;
}

-(void)setLayerContentWithImage: (UIImage *)image;
{
	if (image == nil) {
		[self.activityIndicatorView startAnimating];
		self.layer.contents = nil;
	} else {
		[self removeActivityIndicatorView];

#if MIGA_IOS_4_0_SUPPORTED
		CALayer * rootLayer = self.layer;
		if ([rootLayer respondsToSelector: @selector(setContentsScale:)]) {
			rootLayer.contentsScale = self.imageContentScale;
		}
#endif
		
		self.layer.contents = (id)[image CGImage];
	}
}

-(void)setLayerContentWithMissingImage;
{
	[self removeActivityIndicatorView];
	UIImage *image = [UIImage imageNamed: @"MIGAAsyncImageViewMissingImage.png"];
	if (image) {

#if MIGA_IOS_4_0_SUPPORTED
		CALayer * rootLayer = self.layer;
		if ([rootLayer respondsToSelector: @selector(setContentsScale:)] && [image respondsToSelector: @selector(scale)]) {
			rootLayer.contentsScale = image.scale;
		}
#endif
		
		self.layer.contents = (id)[image CGImage];
	} else {
		self.layer.contents = nil;
	}
}

#pragma mark -
#pragma mark Notification Handlers

-(void)handleMIGAAsyncImageRequestManagerImageDidChangeNotification: (NSNotification *)notification;
{
	NSDictionary * userInfo = [notification userInfo];
	
	if (![[imageURL absoluteString] isEqualToString: [[userInfo objectForKey: MIGAAsyncImageRequestManagerURLUserInfoKey] absoluteString]]) {
		return;
	}
	
	[self setLayerContentWithImage: [userInfo objectForKey: MIGAAsyncImageRequestManagerImageUserInfoKey]];
}

-(void)handleMIGAAsyncImageRequestManagerImageIsUnavailableNotification: (NSNotification *)notification;
{
	NSDictionary * userInfo = [notification userInfo];
	
	if (![[imageURL absoluteString] isEqualToString: [[userInfo objectForKey: MIGAAsyncImageRequestManagerURLUserInfoKey] absoluteString]]) {
		return;
	}
	
	[self setLayerContentWithMissingImage];	
}

@end
