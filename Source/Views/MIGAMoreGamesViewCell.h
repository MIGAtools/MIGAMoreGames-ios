//
//  MIGAMoreGamesViewCell.h
//  MIGAMoreGames
//
//  Created by Darryl H. Thomas on 7/24/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MIGAAsyncImageView.h"

@class MIGAMoreGamesViewCell;

@protocol MIGAMoreGamesViewCellLayoutManager <NSObject>

- (void)performLayoutForCell:(MIGAMoreGamesViewCell *)cell withInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end


@class MIGAGradientView;

@interface MIGAMoreGamesViewCell : UIView {
    @protected
    NSString *reuseIdentifier;

    id<NSObject> tapTarget;
    SEL tapSelector;
    
    MIGAGradientView *headerView;
    MIGAGradientView *contentView;
    UIView *headerSeparatorView;
    
    UIView *gameInfoView;
    
    UILabel *titleLabel;
    UILabel *publisherLabel;
    UILabel *detailLabel;
    MIGAAsyncImageView *iconImageView;
    MIGAAsyncImageView *screenshotImageView;
    
    UIActivityIndicatorView *activityIndicatorView;
}

@property (nonatomic,retain,readonly) NSString *reuseIdentifier;

@property (nonatomic,retain) id<NSObject> tapTarget;
@property (nonatomic,assign) SEL tapSelector;

@property (nonatomic,retain,readonly) MIGAGradientView *headerView;
@property (nonatomic,retain,readonly) MIGAGradientView *contentView;
@property (nonatomic,retain,readonly) UIView *gameInfoView;
@property (nonatomic,retain,readonly) UIView *headerSeparatorView;

@property (nonatomic,retain,readonly) UILabel *titleLabel;
@property (nonatomic,retain,readonly) UILabel *publisherLabel;
@property (nonatomic,retain,readonly) UILabel *detailLabel;
@property (nonatomic,retain,readonly) MIGAAsyncImageView *iconImageView;
@property (nonatomic,retain,readonly) MIGAAsyncImageView *screenshotImageView;

- (id)initWithReuseIdentifier:(NSString *)identifier;

- (void)prepareForReuse;

- (void)startAnimatingActivityIndicatorView;
- (void)stopAnimatingActivityIndicatorView;

- (IBAction)doTap:(id)sender;

@end
