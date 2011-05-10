//
//  MoreGamesStaticExampleViewController.m
//  MoreGamesStaticExample
//
//  Created by Darryl H. Thomas on 8/26/10.
//  Copyright Mobile Independent Gaming Alliance 2010. All rights reserved.
//

#import "MoreGamesStaticExampleViewController.h"

// Make sure you edit your header search paths to include
// MIGAMoreGames/Source recursively.
#import <MIGAMoreGamesViewController.h>

@implementation MoreGamesStaticExampleViewController

- (IBAction)doMoreGamesButtonTap:(id)sender {
    // This is the most basic way of adding MIGAMoreGames support in your
    // app.  When no delegate is specified, the MIGAMoreGamesViewController
    // is self-dismissing when presented modally and self-popping when
    // presented in a Navigation Controller.
    [self presentModalViewController:[MIGAMoreGamesViewController defaultController] animated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


@end
