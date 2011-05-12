//
//  MIGAMoreGamesViewCell.m
//  MIGAMoreGames
//
//  Created by Darryl H. Thomas on 7/24/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "MIGALogging.h"
#import "MIGAMoreGamesViewCell.h"
#import "MIGAGradientView.h"

@interface MIGAMoreGamesViewCell ()

@property (nonatomic,retain,readwrite) NSString *reuseIdentifier;

@property (nonatomic,retain,readwrite) UILabel *titleLabel;
@property (nonatomic,retain,readwrite) UILabel *publisherLabel;
@property (nonatomic,retain,readwrite) UILabel *detailLabel;
@property (nonatomic,retain,readwrite) MIGAAsyncImageView *iconImageView;
@property (nonatomic,retain,readwrite) MIGAAsyncImageView *screenshotImageView;

@property (nonatomic,retain) UIActivityIndicatorView *activityIndicatorView;

- (void)initializeLayers;

@end


@implementation MIGAMoreGamesViewCell

#pragma mark -
#pragma mark Properties

@synthesize reuseIdentifier=_reuseIdentifier;
@synthesize tapTarget=_tapTarget;
@synthesize tapSelector=_tapSelector;
@synthesize headerView=_headerView;
@synthesize contentView=_contentView;
@synthesize gameInfoView=_gameInfoView;
@synthesize titleLabel=_titleLabel;
@synthesize publisherLabel=_publisherLabel;
@synthesize detailLabel=_detailLabel;
@synthesize iconImageView=_iconImageView;
@synthesize screenshotImageView=_screenshotImageView;
@synthesize activityIndicatorView=_activityIndicatorView;

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        CGRect labelFrame = CGRectMake(0, 0, self.gameInfoView.bounds.size.width, 21.0f);
        
        _titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = UITextAlignmentLeft;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.opaque = YES;
        _titleLabel.text = @"Make sure you set a title!";
        
        [self.gameInfoView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)publisherLabel {
    if (!_publisherLabel) {
        CGRect labelFrame = CGRectMake(0, 23.0f, self.gameInfoView.bounds.size.width, 11.0f);
        
        _publisherLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _publisherLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        _publisherLabel.adjustsFontSizeToFitWidth = YES;
        _publisherLabel.numberOfLines = 1;
        _publisherLabel.textAlignment = UITextAlignmentLeft;
        _publisherLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        _publisherLabel.textColor = [UIColor whiteColor];
        _publisherLabel.backgroundColor = [UIColor clearColor];
        _publisherLabel.opaque = YES;
        _publisherLabel.text = @"Make sure you set a publisher!";
        
        [self.gameInfoView addSubview:_publisherLabel];
    }
    
    return _publisherLabel;
}


- (UILabel *)detailLabel {
    if (!_detailLabel) {
        CGRect labelFrame = CGRectMake(126.0f, 41.0f, self.headerView.bounds.size.width - 136.0f, self.headerView.bounds.size.height - 51.0f);
        
        _detailLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _detailLabel.font = [UIFont systemFontOfSize:11.0f];
        _detailLabel.adjustsFontSizeToFitWidth = YES;
        _detailLabel.numberOfLines = 0;
        _detailLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        _detailLabel.textColor = [UIColor whiteColor];
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.opaque = YES;
        _detailLabel.text = @"Make sure you set detail text!";
        
        [self.headerView addSubview:_detailLabel];
    }
    
    return _detailLabel;
}


- (MIGAAsyncImageView *)iconImageView {
    if (!_iconImageView) {
        CGFloat side = self.headerView.bounds.size.height - 20.0f;
        CGRect imageFrame = CGRectMake(10.0, 10.0, side, side);
        
        _iconImageView = [[MIGAAsyncImageView alloc] initWithFrame:imageFrame];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.backgroundColor = [UIColor clearColor];
        _iconImageView.opaque = YES;
                
        [self.headerView addSubview:_iconImageView];
    }
    
    return _iconImageView;
}


- (MIGAAsyncImageView *)screenshotImageView {
    if (!_screenshotImageView) {
        CGRect imageFrame = CGRectMake((self.contentView.bounds.size.width - 240.0f) / 2.0f, 20.0f, 240.0f, 160.0f);
        
        _screenshotImageView = [[MIGAAsyncImageView alloc] initWithFrame:imageFrame];
        _screenshotImageView.contentMode = UIViewContentModeScaleAspectFit;
        _screenshotImageView.backgroundColor = [UIColor clearColor];
        _screenshotImageView.opaque = YES;
                        
        [self.contentView addSubview:_screenshotImageView];

    }
    
    return _screenshotImageView;
}


- (UIView *)headerSeparatorView {
    if (!_headerSeparatorView) {
        CGRect headerSeparatorFrame = CGRectMake(0, self.gameInfoView.bounds.size.height - 1.0f, self.gameInfoView.bounds.size.width, 1.0f);
        
        _headerSeparatorView = [[UIView alloc] initWithFrame:headerSeparatorFrame];
        _headerSeparatorView.opaque = YES;
        _headerSeparatorView.backgroundColor = [UIColor whiteColor];
        _headerSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self.gameInfoView addSubview:_headerSeparatorView];
    }
    
    return _headerSeparatorView;
}


- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        CGFloat midX = CGRectGetMidX(self.bounds);
        CGFloat midY = CGRectGetMidY(self.bounds);
        
        _activityIndicatorView.center = CGPointMake(midX, midY);
        _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        _activityIndicatorView.hidesWhenStopped = YES;
        [_activityIndicatorView stopAnimating];
        
        [self addSubview:_activityIndicatorView];
    }
    
    return _activityIndicatorView;
}


#pragma mark -
#pragma mark Instance Methods

- (id)initWithReuseIdentifier:(NSString *)identifier {
    // TODO: hard-coding is bad, m'kay?
    if ((self = [self initWithFrame:CGRectMake(0, 0, 320.0f, 480.0f)])) {
        self.reuseIdentifier = identifier;
    }
    
    return self;
}


- (id)initWithFrame:(CGRect)aFrame {
    if ((self = [super initWithFrame:aFrame])) {
        self.backgroundColor = [UIColor blackColor];
        self.opaque = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _headerView = [[MIGAGradientView alloc] initWithFrame:CGRectMake(0, 0, aFrame.size.width, 126.0f)];
        _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        _headerView.opaque = YES;
        
        _gameInfoView = [[UIView alloc] initWithFrame:CGRectMake(_headerView.bounds.size.height, 10.0f, _headerView.bounds.size.width - _headerView.bounds.size.height, 36.0f)];
        _gameInfoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        
        _gameInfoView.opaque = NO;
        _gameInfoView.backgroundColor = [UIColor clearColor];
        self.headerSeparatorView.hidden = NO;
        [_headerView addSubview:_gameInfoView];

        
        _contentView = [[MIGAGradientView alloc] initWithFrame:CGRectMake(0, 126.0f, aFrame.size.width, aFrame.size.height - 126.0f)];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _contentView.opaque = YES;
        
        [self addSubview:_headerView];
        [self addSubview:_contentView];
        
        [self initializeLayers];
        
    }
    
    return self;
}


- (void)initializeLayers {
    NSArray *gradientColors;

    gradientColors = [NSArray arrayWithObjects:
                      (id)[[UIColor colorWithRed:56.0/255.0 green:62.0/255.0 blue:68.0/255.0 alpha:1.0f] CGColor],
                      (id)[[UIColor colorWithRed:76.0/255.0 green:84.0/255.0 blue: 88.0/255.0 alpha:1.0f] CGColor],
                      nil];
    
    self.headerView.colors = gradientColors;
            
    gradientColors = [NSArray arrayWithObjects:
                      (id)[[UIColor blackColor] CGColor],
                      nil];
    
    self.contentView.colors = gradientColors;
	
	self.headerView.layer.borderColor = self.contentView.layer.borderColor = [[UIColor blackColor] CGColor];
	self.headerView.layer.borderWidth = self.contentView.layer.borderWidth = 1.0f;
}


- (void)dealloc {
    [_titleLabel release];
    [_publisherLabel release];
    [_detailLabel release];
    [_iconImageView release];
    [_screenshotImageView release];

    [_activityIndicatorView release];
    
    [_headerSeparatorView release];
    [_headerView release];
    [_contentView release];
    [_gameInfoView release];
    
    [_reuseIdentifier release];
    
    [super dealloc];
}


- (void)prepareForReuse {
    [self stopAnimatingActivityIndicatorView];
    self.iconImageView.imageURL = nil;
    self.screenshotImageView.imageURL = nil;
}


- (void)startAnimatingActivityIndicatorView {
    [self.activityIndicatorView startAnimating];
}


- (void)stopAnimatingActivityIndicatorView {
    if (!_activityIndicatorView)
        return;
    
    [self.activityIndicatorView stopAnimating];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self doTap:nil];
}


- (IBAction)doTap:(id)sender {
    if (_tapTarget && _tapSelector && [_tapTarget respondsToSelector:_tapSelector]) {
        [_tapTarget performSelector:_tapSelector withObject:self];
    }
}


@end
