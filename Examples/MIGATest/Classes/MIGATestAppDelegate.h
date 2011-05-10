//
//  MIGATestAppDelegate.h
//  MIGATest
//
//  Created by impact on 7/21/10.
//  Copyright ChickenBrick Studios, LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MIGATestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;

@end

