//
//  RootViewController.h
//  MIGATest
//
//  Created by impact on 7/21/10.
//  Copyright ChickenBrick Studios, LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIGAMoreGamesViewController.h"

@interface RootViewController : UIViewController <UITextFieldDelegate, MIGAMoreGamesViewControllerDelegate> {
    @private
    UIScrollView *optionsScrollView;
    
    UISwitch *customNibSwitch;
    UISwitch *persistentCacheSwitch;
    UISwitch *modalPresentationSwitch;
    UISwitch *portraitOnlySwitch;
    UITextField *appIdTextField;

    UIButton *moreGamesButton;
    
    MIGAMoreGamesViewController *moreGamesViewController;
}

@property (nonatomic,retain) IBOutlet UIScrollView *optionsScrollView;

@property (nonatomic,retain) IBOutlet UISwitch *customNibSwitch;
@property (nonatomic,retain) IBOutlet UISwitch *persistentCacheSwitch;
@property (nonatomic,retain) IBOutlet UISwitch *modalPresentationSwitch;
@property (nonatomic,retain) IBOutlet UISwitch *portraitOnlySwitch;
@property (nonatomic,retain) IBOutlet UITextField *appIdTextField;

@property (nonatomic,retain) IBOutlet UIButton *moreGamesButton;

- (IBAction)showMore;

- (IBAction)doCustomNibSwitchChanged:(id)sender;

@end
