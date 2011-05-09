//
//  MIGAMoreGamesViewController.h
//  MIGAMoreGames
//
//  Created by impact on 7/21/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIGAAsyncHttpRequest.h"
#import "MIGAConf.h"
#import "MIGAMoreGamesView.h"
#import "MIGAMoreGamesDataStore.h"

@class MIGAImpressionTimer;
@class MIGAMoreGamesActivityReportManager;
@class MIGAMoreGamesViewController;

@protocol MIGAMoreGamesViewControllerDelegate <NSObject>

@optional

- (BOOL)migaMoreGamesViewController:(MIGAMoreGamesViewController *)controller shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)migaMoreGamesViewControllerDidCancel:(MIGAMoreGamesViewController *)controller;

@end
    

@interface MIGAMoreGamesViewController : UIViewController <MIGAMoreGamesViewDataSource, MIGAMoreGamesViewDelegate, MIGAMoreGamesViewCellLayoutManager> {
    @private

    UIPageControl *pageControl;
    MIGAMoreGamesView *moreGamesView;
    UIControl *closeButton;
    
    UIView *headerView;
    UILabel *titleLabel;
    UILabel *instructionsLabel;
    
    
    bool pageControlIsChangingPage;
    
    id<MIGAMoreGamesViewControllerDelegate> delegate;
    MIGAMoreGamesDataStore *dataStore;
    
    UIView *loadingView;
    
    MIGAImpressionTimer *impressionTimer;
    MIGAMoreGamesActivityReportManager *activityReportManager;
}

@property (nonatomic,retain) NSString *instructions;

@property (nonatomic,retain) IBOutlet UIView *headerView;
@property (nonatomic,retain) IBOutlet UILabel *titleLabel;
@property (nonatomic,retain) IBOutlet UILabel *instructionsLabel;

@property (nonatomic,retain) IBOutlet UIControl *closeButton;
@property (nonatomic,retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic,retain) IBOutlet MIGAMoreGamesView * moreGamesView;
@property (nonatomic,assign) IBOutlet id<MIGAMoreGamesViewControllerDelegate> delegate;
@property (nonatomic,retain) IBOutlet MIGAMoreGamesDataStore *dataStore;

- (IBAction)doChangePage:(id)sender;
- (IBAction)doDone:(id)sender;
- (IBAction)doCellTap:(id)sender;

+ (id)defaultController;

@end
