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
    NSString *_reuseIdentifier;

    id<NSObject> _tapTarget;
    SEL _tapSelector;
    
    MIGAGradientView *_headerView;
    MIGAGradientView *_contentView;
    UIView *_headerSeparatorView;
    
    UIView *_gameInfoView;
    
    UILabel *_titleLabel;
    UILabel *_publisherLabel;
    UILabel *_detailLabel;
    MIGAAsyncImageView *_iconImageView;
    MIGAAsyncImageView *_screenshotImageView;
    
    UIActivityIndicatorView *_activityIndicatorView;
}

@property (nonatomic,retain,readonly) NSString *reuseIdentifier;

@property (nonatomic,assign) id<NSObject> tapTarget;
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
