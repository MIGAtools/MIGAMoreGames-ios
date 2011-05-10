//
//  MoreGamesStaticExampleAppDelegate.m
//  MoreGamesStaticExample
//
//  Created by Darryl H. Thomas on 8/26/10.
//  Copyright Mobile Independent Gaming Alliance 2010. All rights reserved.
//

#import "MoreGamesStaticExampleAppDelegate.h"
#import "MoreGamesStaticExampleViewController.h"

@implementation MoreGamesStaticExampleAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

    return YES;
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}

@end
