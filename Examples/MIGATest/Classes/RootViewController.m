//
//  RootViewController.m
//  MIGATest
//
//  Created by impact on 7/21/10.
//  Copyright ChickenBrick Studios, LLC 2010. All rights reserved.
//

#import "RootViewController.h"
#import "MIGAPersistentCacheManager.h"
#import "MIGAAvailability.h"

@interface RootViewController ()
-(void)handleUIKeyboardWillShowNotification: (NSNotification *)notification;
-(void)handleUIKeyboardWillHideNotification: (NSNotification *)notification;
@end

@implementation RootViewController
@synthesize optionsScrollView;
@synthesize customNibSwitch, persistentCacheSwitch, modalPresentationSwitch, portraitOnlySwitch;
@synthesize appIdTextField;
@synthesize moreGamesButton;

-(void)viewDidLoad;
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"MIGAMoreGames Example", @"MIGAMoreGames Example");
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"MIGA Example", @"MIGA Example") style: UIBarButtonItemStylePlain target: nil action: nil] autorelease];

	CGSize optionsContentSize = self.optionsScrollView.bounds.size;
	CGRect lastOptionControlRect = self.moreGamesButton.frame;
	
	optionsContentSize.height = lastOptionControlRect.origin.y + lastOptionControlRect.size.height + 20.0f;
	self.optionsScrollView.contentSize = optionsContentSize;
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver: self selector: @selector(handleUIKeyboardWillShowNotification:) name: UIKeyboardWillShowNotification object: self.view.window];
	[center addObserver: self selector: @selector(handleUIKeyboardWillHideNotification:) name: UIKeyboardWillHideNotification object: self.view.window];
	
	self.optionsScrollView.clipsToBounds = YES;	
}

-(void)dealloc;
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[customNibSwitch release];
	[persistentCacheSwitch release];
	[modalPresentationSwitch release];
	[portraitOnlySwitch release];
	[appIdTextField release];
	[moreGamesButton release];
	[moreGamesViewController release];
	[optionsScrollView release];
	
	[super dealloc];
}

-(void)viewDidUnload;
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	self.customNibSwitch = nil;
	self.modalPresentationSwitch = nil;
	self.portraitOnlySwitch = nil;
	self.appIdTextField = nil;
	self.moreGamesButton = nil;
	self.optionsScrollView = nil;
}

-(void)didReceiveMemoryWarning;
{
	[super didReceiveMemoryWarning];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
	return YES;
}

#pragma mark -
#pragma mark Actions

-(IBAction)showMore;
{	
	MIGAMoreGamesViewController *controller = nil;
	
	if (self.customNibSwitch.on) {
		controller = [[MIGAMoreGamesViewController alloc] initWithNibName: @"CustomMIGAMoreGamesViewController" bundle: nil];
	} else {
		controller = [[MIGAMoreGamesViewController defaultController] retain];
	}
	
	controller.delegate = self;	

	if (self.customNibSwitch.on && self.persistentCacheSwitch.on) {
		
		NSString *sourceURLString = [NSString stringWithFormat: @"%@%@", DEFAULT_MIGA_HOST_BASE, DEFAULT_MIGA_MORE_GAMES_CONTENT_PATH];
		NSURL *sourceURL = [NSURL URLWithString: sourceURLString];
		
		MIGAPersistentCacheManager *cacheManager = [MIGAPersistentCacheManager defaultManager];
		
		controller.dataStore = [[[MIGAMoreGamesDataStore alloc] initWithAsynchronousRequestToURL: sourceURL cacheManager: cacheManager] autorelease];
	}	
	
	if (self.modalPresentationSwitch.on) {
		moreGamesViewController = [controller retain];
		
		if (customNibSwitch.on) {
			controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		}
		
		[self.navigationController presentModalViewController: controller animated: YES];
	} else {
		[self.navigationController pushViewController: controller animated: YES];
	}
	
	[controller release];
}

-(IBAction)doCustomNibSwitchChanged: (id)sender;
{
    self.appIdTextField.enabled = self.customNibSwitch.on;
	self.persistentCacheSwitch.enabled = self.customNibSwitch.on;
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField;
{
	[textField resignFirstResponder];
	return NO;
}

#pragma mark -
#pragma mark MIGAMoreGamesViewControllerDelegate Methods

-(BOOL)migaMoreGamesViewController:(MIGAMoreGamesViewController *)controller shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{	
	if (portraitOnlySwitch.on) {
		return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
	}
	
	return YES;
}

-(void)migaMoreGamesViewControllerDidCancel:(MIGAMoreGamesViewController *)controller;
{
	if (moreGamesViewController) {
		[self.navigationController dismissModalViewControllerAnimated: YES];
		[moreGamesViewController release];
		moreGamesViewController = nil;
	} else {
		[self.navigationController popViewControllerAnimated: YES];
	}
}

// Ignoring use of UIKeyboardBoundsUserInfoKey
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

-(void)handleUIKeyboardWillShowNotification: (NSNotification *)notification;
{
	CGRect keyboardRect = CGRectZero;

#if MIGA_IOS_3_2_SUPPORTED
	if (&UIKeyboardFrameEndUserInfoKey != NULL) {
		keyboardRect = [[[notification userInfo] objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue];
		keyboardRect = [self.view.window convertRect: keyboardRect toView: self.view];

	} else
#endif		
	{
		keyboardRect = [[[notification userInfo] objectForKey: UIKeyboardBoundsUserInfoKey] CGRectValue];
		keyboardRect.origin.y = (self.view.window.frame.size.height - keyboardRect.size.height);
	}
	
	UIEdgeInsets optionsScrollViewContentInset = self.optionsScrollView.contentInset;
	optionsScrollViewContentInset.bottom = (self.view.bounds.size.height - keyboardRect.origin.y);
	self.optionsScrollView.contentInset = optionsScrollViewContentInset;
}

#pragma GCC diagnostic warning "-Wdeprecated-declarations"

-(void)handleUIKeyboardWillHideNotification: (NSNotification *)notification;
{
	UIEdgeInsets optionsScrollViewContentInset = self.optionsScrollView.contentInset;
	optionsScrollViewContentInset.bottom = 0;
	self.optionsScrollView.contentInset = optionsScrollViewContentInset;
}

@end

