//
//  MIGAMoreGamesViewController.m
//  MIGAMoreGames
//
//  Created by impact on 7/21/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "MIGAConf.h"
#import "MIGAAvailability.h"
#import "MIGALogging.h"
#import "MIGAMoreGamesViewController.h"
#import "JSON.h"
#import "MIGAPersistentCacheManager.h"
#import "MIGAGradientView.h"
#import "MIGACloseButton.h"
#import "MIGAImpressionTimer.h"
#import "MIGAMoreGamesActivityReportManager.h"

#define MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_PORTRAIT 12.0f
#define MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_LANDSCAPE 8.0f

@interface MIGAMoreGamesViewController ()

@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) MIGAImpressionTimer *impressionTimer;

-(void)layoutCellForPortaitOrientation: (MIGAMoreGamesViewCell *)cell;
-(void)layoutCellForLandscapeOrientation: (MIGAMoreGamesViewCell *)cell;

-(void)presentLoadingView;
-(void)dismissLoadingView;
-(void)loadingViewFadeOutAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
-(void)removeLoadingView;

-(void)beginImpression: (NSUInteger)contentId;
-(void)endImpression;

-(void)handleMIGAMoreGamesDataStoreDidUpdateNotification: (NSNotification *)notification;

@end

@implementation MIGAMoreGamesViewController

#pragma mark -
#pragma mark Properties

@synthesize pageControl, delegate;
@synthesize moreGamesView;
@synthesize closeButton;
@synthesize headerView, titleLabel, instructionsLabel;
@synthesize loadingView, impressionTimer;

-(void)setDataStore:(MIGAMoreGamesDataStore *)aDataStore;
{
	if (dataStore == aDataStore)
		return;
	
	NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
	
	[center removeObserver: self name: MIGAMoreGamesDataStoreDidUpdateNotification object: dataStore];
	[aDataStore retain];
	[dataStore release];
	dataStore = aDataStore;
	
	[center addObserver: self selector: @selector(handleMIGAMoreGamesDataStoreDidUpdateNotification:) name: MIGAMoreGamesDataStoreDidUpdateNotification object: dataStore];
}

-(MIGAMoreGamesDataStore *)dataStore;
{
	if (!dataStore) {
		self.dataStore = [[[MIGAMoreGamesDataStore alloc] initWithDefaultContent] autorelease];
	}
	
	return dataStore;
}

-(void)setTitle:(NSString *)aTitle;
{
	[super setTitle: aTitle];
	
	self.titleLabel.text = aTitle;
}

-(UIView *)loadingView;
{
	if (!loadingView) {
		CGRect tmpRect = CGRectMake(0, self.headerView.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.headerView.bounds.size.height);
		UILabel *tmpLabel = nil;
		MIGAGradientView *tmpView = [[MIGAGradientView alloc] initWithFrame: tmpRect];
		
		tmpView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		tmpView.colors = [NSArray arrayWithObjects:
											(id)[[UIColor darkGrayColor] CGColor],
											(id)[[UIColor blackColor] CGColor],
											nil];
		
		UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
		[tmpView addSubview: indicatorView];
		indicatorView.center = CGPointMake(CGRectGetMidX(tmpView.bounds),floorf(self.view.bounds.size.height / 3.0f));
		indicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
		[indicatorView startAnimating];
		[indicatorView release];
		
		tmpRect = CGRectMake(20.0f, 20.0f, self.view.bounds.size.width - 40.0f, 44.0f);
		tmpLabel = [[UILabel alloc] initWithFrame: tmpRect];
		tmpLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		tmpLabel.font = [UIFont systemFontOfSize: 36.0f];
		tmpLabel.numberOfLines = 1;
		tmpLabel.adjustsFontSizeToFitWidth = YES;
		tmpLabel.textAlignment = UITextAlignmentCenter;
		tmpLabel.text = NSLocalizedString(@"Updating Games List...", @"Updating Games List...");
		tmpLabel.opaque = YES;
		tmpLabel.textColor = [UIColor whiteColor];
		tmpLabel.backgroundColor = [UIColor clearColor];
		[tmpView addSubview: tmpLabel];
		[tmpLabel release];
		
		tmpRect = CGRectMake(20.0f, floorf(self.view.bounds.size.height / 2.0f), self.view.bounds.size.width - 40.0f, floorf((self.view.bounds.size.height / 3.0f)));
		tmpLabel = [[UILabel alloc] initWithFrame: tmpRect];
		tmpLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
		tmpLabel.font = [UIFont systemFontOfSize: 18.0f];
		tmpLabel.numberOfLines = 0;
		tmpLabel.adjustsFontSizeToFitWidth = YES;
		tmpLabel.textAlignment = UITextAlignmentCenter;
		tmpLabel.lineBreakMode = UILineBreakModeWordWrap;
		tmpLabel.text = NSLocalizedString(@"This won't take long.  We'll have a list of fun games produced by independent studios for you in just a moment.", @"This won't take long.  We'll have a list of fun games produced by independent studios for you in just a moment.");
		tmpLabel.opaque = YES;
		tmpLabel.textColor = [UIColor whiteColor];
		tmpLabel.backgroundColor = [UIColor clearColor];
		[tmpView addSubview: tmpLabel];
		[tmpLabel release];
		
		
		loadingView = tmpView;
	}
	
	return loadingView;
}

-(MIGAImpressionTimer *)impressionTimer;
{
	if (!impressionTimer) {
		impressionTimer = [[MIGAImpressionTimer alloc] init];
	}
	
	return impressionTimer;
}

#pragma mark -
#pragma mark Class Methods

static MIGAMoreGamesViewController *defaultMIGAMoreGamesViewController = nil;
+ (id)defaultController;
{
	if (!defaultMIGAMoreGamesViewController) {
		defaultMIGAMoreGamesViewController = [[MIGAMoreGamesViewController alloc] init];

		NSString *sourceURLString = [NSString stringWithFormat: @"%@%@", DEFAULT_MIGA_HOST_BASE, DEFAULT_MIGA_MORE_GAMES_CONTENT_PATH];
		NSURL *sourceURL = [NSURL URLWithString: sourceURLString];

		MIGAPersistentCacheManager *cacheManager = [MIGAPersistentCacheManager defaultManager];
		

		MIGAMoreGamesDataStore *store = [[MIGAMoreGamesDataStore alloc] initWithAsynchronousRequestToURL: sourceURL cacheManager: cacheManager];
		
		defaultMIGAMoreGamesViewController.dataStore = store;
		
		[store release];
	}
	
	return defaultMIGAMoreGamesViewController;
}

-(void)setInstructions:(NSString *)aValue;
{
	self.instructionsLabel.text = aValue;
}

-(NSString *)instructions;
{
	return self.instructionsLabel.text;
}

#pragma mark -
#pragma mark Instance Methods

-(void)loadView;
{
	// If a nib was specified, we use the super implementation.
	if (self.nibName) {
		[super loadView];
		return;
	}
	
	self.view = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame]];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view.backgroundColor = [UIColor blackColor];
	self.view.opaque = YES;
	
	CGRect subviewFrame = self.view.bounds;
	subviewFrame.origin.y += 48.0f;
	subviewFrame.size.height -= 48.0f;
	
	self.moreGamesView = [[[MIGAMoreGamesView alloc] initWithFrame: subviewFrame] autorelease];
	self.moreGamesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.moreGamesView.dataSource = self;
	self.moreGamesView.cellLayoutManager = self;
	
	[self.view addSubview: self.moreGamesView];
	
	subviewFrame.origin.y = self.view.bounds.size.height - 36.0f;
	subviewFrame.size.height = 36.0f;
	self.pageControl = [[[UIPageControl alloc] initWithFrame: subviewFrame] autorelease];
	self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

	[self.pageControl addTarget: self action: @selector(doChangePage:) forControlEvents: UIControlEventValueChanged];

	[self.view addSubview: self.pageControl];

	headerView = [[MIGAGradientView alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, 48.0f)];
	((MIGAGradientView *)headerView).colors = [NSArray arrayWithObjects:
																						 (id)[[UIColor whiteColor] CGColor],
																						 (id)[[UIColor darkGrayColor] CGColor],
																						 nil];
	headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	
	closeButton = [[MIGACloseButton alloc] initWithFrame: CGRectMake(6.0f, 6.0f, 24.0f, 24.0f)];
	closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	[closeButton addTarget: self action: @selector(doDone:) forControlEvents: UIControlEventTouchUpInside];
	[headerView addSubview: closeButton];
	
	titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(36.0f, 6.0f, headerView.bounds.size.width - 42.0f, 12.0f)];
	titleLabel.font = [UIFont boldSystemFontOfSize: 12.0f];
	titleLabel.numberOfLines = 1;
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.opaque = NO;
	titleLabel.adjustsFontSizeToFitWidth = YES;
	titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	[headerView addSubview: titleLabel];
	
	instructionsLabel = [[UILabel alloc] initWithFrame: CGRectMake(36.0f, 22.0f, headerView.bounds.size.width - 42.0f, headerView.bounds.size.height - 26.0f)];
	instructionsLabel.font = [UIFont systemFontOfSize: 9.0f];
	instructionsLabel.numberOfLines = 2;
	instructionsLabel.lineBreakMode = UILineBreakModeWordWrap;
	instructionsLabel.textColor = [UIColor blackColor];
	instructionsLabel.backgroundColor = [UIColor clearColor];
	instructionsLabel.opaque = NO;
	instructionsLabel.adjustsFontSizeToFitWidth = YES;
	instructionsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
	
	[headerView addSubview: instructionsLabel];
	
	[self.view addSubview: headerView];
}

-(void)viewDidLoad;
{
	[super viewDidLoad];
	
	activityReportManager = [MIGAMoreGamesActivityReportManager sharedManager];

	if (!self.moreGamesView.moreGamesViewDelegate) {
		self.moreGamesView.moreGamesViewDelegate = self;
	}
	
	// Bit of a hack to force the page control to properly update when the number
	// of pages is set. I don't fully understand why it works, but it does.
	self.pageControl.numberOfPages = 2;
	self.pageControl.currentPage = 1;
	
	self.pageControl.numberOfPages = 0;
	self.pageControl.currentPage = 0;

	self.pageControl.defersCurrentPageDisplay = NO;
	
	if (!self.title) {
		self.title = NSLocalizedString(@"Discover More Games!", @"Discover More Games!");
	}

	if (!self.instructions) {
		self.instructions = NSLocalizedString(@"If you've enjoyed this game, you may also enjoy the following titles. Tap on any game to learn more on the App Store™.", @"If you've enjoyed this game, you may also enjoy the following titles. Tap on any game to learn more on the App Store™.");
	}
}

-(void)dealloc;
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[moreGamesView release];
	[dataStore release];
		
	[pageControl release];
	
	[closeButton release];
	[titleLabel release];
	[instructionsLabel release];
	[headerView release];
	[loadingView release];

	
	[impressionTimer stop];
	[impressionTimer release];
	
	[super dealloc];
}

-(void)viewDidUnload;
{
	[super viewDidUnload];
	
	[self removeLoadingView];
	
	self.moreGamesView = nil;
	self.pageControl = nil;
	
	self.closeButton = nil;
	self.titleLabel = nil;
	self.instructionsLabel = nil;
	self.headerView = nil;
	
	[impressionTimer stop];
	self.impressionTimer = nil;
}

-(void)didReceiveMemoryWarning;
{
	[super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated;
{
	[super viewWillAppear: animated];

	self.moreGamesView.interfaceOrientation = self.interfaceOrientation;
	[self.dataStore update];
	[self.moreGamesView reloadData];
	if ([self.dataStore count] < 1) {
		[self presentLoadingView];
	}
}

-(void)viewDidAppear:(BOOL)animated;
{
	[super viewDidAppear: animated];
	
	[activityReportManager logPresentationWithDate: [NSDate date]];	
}

-(void)viewWillDisappear:(BOOL)animated;
{
	[super viewWillDisappear: animated];
	
	[self endImpression];
	[activityReportManager logDismissalWithDate: [NSDate date]];
}

-(void)viewDidDisappear:(BOOL)animated;
{
	[super viewDidDisappear: animated];
	
	[activityReportManager submitActivity];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
	if (delegate && [delegate respondsToSelector: @selector(migaMoreGamesViewController:shouldAutorotateToInterfaceOrientation:)]) {
		return [delegate migaMoreGamesViewController: self shouldAutorotateToInterfaceOrientation: toInterfaceOrientation];
	}
	
	return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
	[super willRotateToInterfaceOrientation: toInterfaceOrientation duration: duration];
	
	[self.moreGamesView layoutCellsForInterfaceOrientation: toInterfaceOrientation duration: duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
{
	self.moreGamesView.interfaceOrientation = self.interfaceOrientation;
}

-(void)presentLoadingView;
{
	if (self.loadingView.superview == nil) {
		self.loadingView.alpha = 1.0f;
		[self.view addSubview: self.loadingView];
	}
}

-(void)dismissLoadingView;
{
	if (loadingView) {
		[UIView beginAnimations: @"loadingViewFadeOut" context: NULL];
		[UIView setAnimationDuration: 0.33f];
		self.loadingView.alpha = 0.0f;
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector: @selector(loadingViewFadeOutAnimationDidStop:finished:context:)];
		[UIView commitAnimations];
	}
}

-(void)loadingViewFadeOutAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if (![animationID isEqualToString: @"loadingViewFadeOut"])
		return;
	
	[self removeLoadingView];
}

-(void)removeLoadingView;
{
	if (loadingView) {
		[loadingView removeFromSuperview];
		[loadingView release];
		loadingView = nil;
	}	
}

-(void)beginImpression: (NSUInteger)contentId;
{
	[self.impressionTimer reset];
	self.impressionTimer.contentId = contentId;
	[self.impressionTimer start];
}

-(void)endImpression;
{
	[self.impressionTimer stop];
	if (self.impressionTimer.contentId == 0)
		return;
	
	[activityReportManager logImpressionWithDate: self.impressionTimer.lastResetDate contentId: self.impressionTimer.contentId duration: self.impressionTimer.elapsedTime];
}

#pragma mark -
#pragma mark Actions

-(IBAction)doChangePage:(id)sender;
{
	pageControlIsChangingPage = YES;
	[self endImpression];
	self.moreGamesView.currentPage = pageControl.currentPage;
	[self beginImpression: [[self.dataStore applicationAtIndex: pageControl.currentPage] contentId]];
	pageControlIsChangingPage = NO;
}

-(IBAction)doDone:(id)sender;
{
	if (delegate && [delegate respondsToSelector: @selector(migaMoreGamesViewControllerDidCancel:)]) {
		[delegate migaMoreGamesViewControllerDidCancel: self];
	} else {
		if ((self.parentViewController) && (self.parentViewController.modalViewController == self)) {
			[self retain];
			[self.parentViewController dismissModalViewControllerAnimated: YES];
			[self autorelease];
		} else if (self.navigationController) {
			[self retain];
			[self.navigationController popViewControllerAnimated: YES];
			[self autorelease];
		} else {
			[self.view removeFromSuperview];
		}
	}
}

-(IBAction)doCellTap:(id)sender;
{
	NSUInteger index = [self.moreGamesView currentPage];
	
	assert(index < [self.dataStore count]);
	
	MIGAApplicationInfo *info = [self.dataStore applicationAtIndex: index];
	if (!info) {
		return;
	}
	
	[activityReportManager logClickWithDate: [NSDate date] contentId: info.contentId];
	
	NSURL *appURL = [NSURL URLWithString: info.clickURLString];
	if (!appURL || [appURL isFileURL]) {
		[[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Unable to Show Application.", @"Unable to Show Application.") message: NSLocalizedString(@"Sorry for the inconvenience.  We're unable to display more information about this game at this time.", @"Sorry for the inconvenience.  We're unable to display more information about this game at this time.") delegate: nil cancelButtonTitle: NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles: nil, nil] autorelease] show];
		return;
	}
	
#if TARGET_IPHONE_SIMULATOR
	[[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"iOS Device Required", @"iOS Device Required") message: NSLocalizedString(@"This functionality does not work on the iOS Simulator.  To test App Store links, please install this app on a device.", @"This functionality does not work on the iOS Simulator.  To test App Store links, please install this app on a device.") delegate: nil cancelButtonTitle: NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles: nil, nil] autorelease] show];
#else
	[[UIApplication sharedApplication] openURL: appURL];
#endif
	
}

#pragma mark -
#pragma mark MIGAMoreGamesViewDataSource Methods

-(NSUInteger)numberOfApplicationsInMoreGamesView:(MIGAMoreGamesView *)moreGamesView;
{
	NSUInteger result = [self.dataStore count];
	self.pageControl.numberOfPages = result;
	
	return result;
}

-(MIGAMoreGamesViewCell *)migaMoreGamesView:(MIGAMoreGamesView *)aMoreGamesView cellForApplicationAtIndex:(NSUInteger)index;
{
	static NSString *identifier = @"Cell";
	
	assert(index < [self.dataStore count]);
	
	MIGAMoreGamesViewCell *result = [moreGamesView dequeueReusableCellWithIdentifier: identifier];
	if (!result) {
		result = [[[MIGAMoreGamesViewCell alloc] initWithReuseIdentifier: identifier] autorelease];
		result.tapTarget = self;
		result.tapSelector = @selector(doCellTap:);
	}
			
	MIGAApplicationInfo *info = [self.dataStore applicationAtIndex: index];
	[CATransaction begin];
	[CATransaction setDisableActions: YES];
	
	NSArray *gradientColors;
	if (index % 2) {
		gradientColors = [NSArray arrayWithObjects:
											(id)[[UIColor colorWithRed: 56.0/255.0	green: 62.0/255.0	blue: 68.0/255.0 alpha: 1.0f] CGColor],
											(id)[[UIColor colorWithRed: 76.0/255.0 green: 84.0/255.0 blue: 88.0/255.0 alpha: 1.0f] CGColor],
											nil];
	} else {
		gradientColors = [NSArray arrayWithObjects:
											(id)[[UIColor colorWithRed: 62.0/255.0	green: 70.0/255.0	blue: 74.0/255.0 alpha: 1.0f] CGColor],
											(id)[[UIColor colorWithRed: 82.0/255.0 green: 90.0/255.0 blue: 94.0/255.0 alpha: 1.0f] CGColor],
											nil];		
	}
	
	
	result.headerView.colors = gradientColors;
	
	result.titleLabel.text = info.title;
	result.publisherLabel.text = info.publisher;
	result.detailLabel.text = info.detail;
	if (info.backgroundColor) {
		result.contentView.colors = [NSArray arrayWithObjects:
																 (id)[info.backgroundColor CGColor],
																 (id)[[UIColor blackColor] CGColor],
																 nil];
	} else {
		result.contentView.colors = [NSArray arrayWithObjects:
																 (id)[[UIColor blackColor] CGColor],
																 nil];
	}
	
	NSURL *url = nil;
	CGSize imageSize = CGSizeZero;
	CGFloat desiredScale = 1.0;
	CGFloat actualScale = 1.0;
#if MIGA_IOS_4_0_SUPPORTED
	UIScreen *screen = [UIScreen mainScreen];
	if ((self.view != nil) && (self.view.window != nil)) {
		if ([self.view.window respondsToSelector: @selector(screen)]) {
			screen = [self.view.window screen];
		}
	}
	
	if ([screen respondsToSelector: @selector(scale)]) {
		desiredScale = screen.scale;
	}
	
#endif
	
	imageSize = CGSizeMake(57.0f, 57.0f);
	url = [info imageURLForType: kMIGAApplicationInfoIconImageType size: imageSize contentScale: desiredScale actualScale: &actualScale];
	result.iconImageView.nativeImageSize = imageSize;
	result.iconImageView.imageContentScale = actualScale;
	result.iconImageView.imageURL = url;
	
	imageSize = CGSizeMake(240.0f, 160.0f);
	url = [info imageURLForType: kMIGAApplicationInfoScreenshotImageType size: imageSize contentScale: desiredScale actualScale: &actualScale];
	result.screenshotImageView.nativeImageSize = imageSize;
	result.screenshotImageView.imageContentScale = actualScale;
	result.screenshotImageView.imageURL = url;

	[self performLayoutForCell: result withInterfaceOrientation: self.moreGamesView.interfaceOrientation];

	[CATransaction commit];
	return result;
}

#pragma mark -
#pragma mark MIGAMoreGamesViewDelegate Methods

-(void)migaMoreGamesView:(MIGAMoreGamesView *)aMoreGamesView didScrollToPage:(NSUInteger)page;
{
	[self endImpression];
	self.pageControl.currentPage = page;
	[self beginImpression: [[self.dataStore applicationAtIndex: page] contentId]];
}

#pragma mark -
#pragma mark MIGAMoreGamesViewCellLayoutManager Methods

-(void)performLayoutForCell:(MIGAMoreGamesViewCell *)cell withInterfaceOrientation:(UIInterfaceOrientation)orientation;
{
	if (UIInterfaceOrientationIsPortrait(orientation)) {
		[self layoutCellForPortaitOrientation: cell];
	} else {
		[self layoutCellForLandscapeOrientation: cell];
	}
}

-(void)layoutCellForPortaitOrientation: (MIGAMoreGamesViewCell *)cell;
{
	CGRect targetBounds = self.moreGamesView.bounds;

	CGFloat textWidth = targetBounds.size.width - (2.0f *MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_PORTRAIT);
	CGSize textSize = [cell.detailLabel.text sizeWithFont: cell.detailLabel.font constrainedToSize: CGSizeMake(textWidth, targetBounds.size.height) lineBreakMode: cell.detailLabel.lineBreakMode];
	
	CGRect newFrame = targetBounds;
	newFrame.origin = cell.frame.origin;
	cell.frame = newFrame;
	
	cell.headerView.frame = CGRectMake(0, 0, targetBounds.size.width, 54.0f + (3.0f * MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_PORTRAIT) + textSize.height);
	cell.iconImageView.frame = CGRectMake(MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_PORTRAIT, MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_PORTRAIT, 54.0f, 54.0f);
	cell.gameInfoView.frame = CGRectMake(54.0f + (2.0f * MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_PORTRAIT), 20.0f, cell.headerView.bounds.size.width - (54.0f + (3.0f * MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_PORTRAIT)), 36.0f);
	
	cell.detailLabel.frame = CGRectMake(MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_PORTRAIT, 54.0f + (2.0f * MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_PORTRAIT), cell.headerView.bounds.size.width - (2.0f * MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_PORTRAIT), textSize.height);
	cell.detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;	
	
	cell.contentView.frame = CGRectMake(0, cell.headerView.bounds.size.height, targetBounds.size.width, targetBounds.size.height - cell.headerView.bounds.size.height);
	cell.screenshotImageView.frame = CGRectMake((targetBounds.size.width - 240.0f) / 2.0f, (cell.contentView.bounds.size.height - 20.0f - 160.0f) / 2.0f, 240.0f, 160.0f);
	cell.screenshotImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;

	
}

-(void)layoutCellForLandscapeOrientation: (MIGAMoreGamesViewCell *)cell;
{
	CGFloat textWidth;
	CGSize textSize;
	CGRect targetBounds = self.moreGamesView.bounds;
	CGRect newFrame = targetBounds;
	newFrame.origin = cell.frame.origin;
	cell.frame = newFrame;
	
	cell.headerView.frame = CGRectMake(0, 0, targetBounds.size.width - 280.0f, targetBounds.size.height);
	cell.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
	
	cell.iconImageView.frame = CGRectMake(MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_LANDSCAPE, MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_LANDSCAPE, 54.0f, 54.0f);
	cell.gameInfoView.frame = CGRectMake(54.0f + (2.0f * MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_LANDSCAPE),  20.0f, cell.headerView.bounds.size.width - (54.0f + (3.0f * MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_LANDSCAPE)), 36.0f);

	textWidth = cell.headerView.bounds.size.width - (2.0f * MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_LANDSCAPE);
	textSize = [cell.detailLabel.text sizeWithFont: cell.detailLabel.font constrainedToSize: CGSizeMake(textWidth, cell.headerView.bounds.size.height - (3.0f * MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_LANDSCAPE)) lineBreakMode: cell.detailLabel.lineBreakMode];
	
	cell.detailLabel.frame = CGRectMake(MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_LANDSCAPE, 54.0f + (2.0f * MIGA_MORE_GAMES_VIEW_CONTROLLER_DEFAULT_ELEMENT_GUTTER_LANDSCAPE), textSize.width, textSize.height);
	cell.detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;

	
	cell.contentView.frame = CGRectMake(targetBounds.size.width - 280.0f, 0, 280.0f, targetBounds.size.height);
	cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleHeight;
	
	cell.screenshotImageView.frame = CGRectMake((cell.contentView.bounds.size.width - 240.0f) / 2.0f, (cell.contentView.bounds.size.height - 160.0f) / 2.0f, 240.0f, 160.0f);
	cell.screenshotImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;

}

#pragma mark -
#pragma mark Notification Handlers

-(void)handleMIGAMoreGamesDataStoreDidUpdateNotification:(NSNotification *)notification;
{
	[self.moreGamesView reloadData];
	self.pageControl.currentPage = 0;

	[self performSelector: @selector(dismissLoadingView) withObject: nil afterDelay: 1.0];
}

@end
