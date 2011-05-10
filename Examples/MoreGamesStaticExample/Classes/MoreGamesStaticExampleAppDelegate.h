//
//  MoreGamesStaticExampleAppDelegate.h
//  MoreGamesStaticExample
//
//  Created by Darryl H. Thomas on 8/26/10.
//  Copyright Mobile Independent Gaming Alliance 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MoreGamesStaticExampleViewController;

@interface MoreGamesStaticExampleAppDelegate : NSObject <UIApplicationDelegate> {
    @private
    UIWindow *window;
    MoreGamesStaticExampleViewController *viewController;
}

@property (nonatomic,retain) IBOutlet UIWindow *window;
@property (nonatomic,retain) IBOutlet MoreGamesStaticExampleViewController *viewController;

@end

