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

@synthesize reuseIdentifier;
@synthesize tapTarget, tapSelector;
@synthesize headerView, contentView;
@synthesize gameInfoView;
@synthesize titleLabel, publisherLabel, detailLabel, iconImageView, screenshotImageView;
@synthesize activityIndicatorView;

- (UILabel *)titleLabel {
    if (!titleLabel) {
        CGRect labelFrame = CGRectMake(0, 0, gameInfoView.bounds.size.width, 21.0f);
        
        titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.numberOfLines = 1;
        titleLabel.textAlignment = UITextAlignmentLeft;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.opaque = NO;
        titleLabel.text = @"Make sure you set a title!";
        
        [gameInfoView addSubview:titleLabel];
    }
    
    return titleLabel;
}

- (UILabel *)publisherLabel {
    if (!publisherLabel) {
        CGRect labelFrame = CGRectMake(0, 23.0f, gameInfoView.bounds.size.width, 11.0f);
        
        publisherLabel = [[UILabel alloc] initWithFrame:labelFrame];
        publisherLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        publisherLabel.adjustsFontSizeToFitWidth = YES;
        publisherLabel.numberOfLines = 1;
        publisherLabel.textAlignment = UITextAlignmentLeft;
        publisherLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        publisherLabel.textColor = [UIColor whiteColor];
        publisherLabel.backgroundColor = [UIColor clearColor];
        publisherLabel.opaque = NO;
        publisherLabel.text = @"Make sure you set a publisher!";
        
        [gameInfoView addSubview:publisherLabel];
    }
    
    return publisherLabel;
}


- (UILabel *)detailLabel {
    if (!detailLabel) {
        CGRect labelFrame = CGRectMake(126.0f, 41.0f, headerView.bounds.size.width - 136.0f, headerView.bounds.size.height - 51.0f);
        
        detailLabel = [[UILabel alloc] initWithFrame:labelFrame];
        detailLabel.font = [UIFont systemFontOfSize:11.0f];
        detailLabel.adjustsFontSizeToFitWidth = YES;
        detailLabel.numberOfLines = 0;
        detailLabel.lineBreakMode = UILineBreakModeTailTruncation;
        detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        detailLabel.textColor = [UIColor whiteColor];
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.opaque = NO;
        detailLabel.text = @"Make sure you set detail text!";
        
        [headerView addSubview:detailLabel];
    }
    
    return detailLabel;
}


- (MIGAAsyncImageView *)iconImageView {
    if (!iconImageView) {
        CGFloat side = headerView.bounds.size.height - 20.0f;
        CGRect imageFrame = CGRectMake(10.0, 10.0, side, side);
        
        iconImageView = [[MIGAAsyncImageView alloc] initWithFrame:imageFrame];
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        iconImageView.backgroundColor = [UIColor clearColor];
        iconImageView.opaque = YES;
                
        [headerView addSubview:iconImageView];
    }
    
    return iconImageView;
}


- (MIGAAsyncImageView *)screenshotImageView {
    if (!screenshotImageView) {
        CGRect imageFrame = CGRectMake((contentView.bounds.size.width - 240.0f) / 2.0f, 20.0f, 240.0f, 160.0f);
        
        screenshotImageView = [[MIGAAsyncImageView alloc] initWithFrame:imageFrame];
        screenshotImageView.contentMode = UIViewContentModeScaleAspectFit;
        screenshotImageView.backgroundColor = [UIColor clearColor];
        screenshotImageView.opaque = YES;
                        
        [contentView addSubview:screenshotImageView];

#ifdef MIGA_MORE_GAMES_VIEW_CELL_TRANSFORM_SCREENSHOTS
        imageView.layer.anchorPoint = CGPointMake(1, 0.5);
        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform.m34 = 1.0 / -250;
        rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform,  0.75, 0.75, 0.75);
        rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 120, 0, 0);
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 30.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
        imageView.layer.transform = rotationAndPerspectiveTransform;

        imageView.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerTopEdge | kCALayerBottomEdge;
#endif
    }
    
    return screenshotImageView;
}


- (UIView *)headerSeparatorView {
    if (!headerSeparatorView) {
        CGRect headerSeparatorFrame = CGRectMake(0, gameInfoView.bounds.size.height - 1.0f, gameInfoView.bounds.size.width, 1.0f);
        
        headerSeparatorView = [[UIView alloc] initWithFrame:headerSeparatorFrame];
        headerSeparatorView.opaque = YES;
        headerSeparatorView.backgroundColor = [UIColor whiteColor];
        headerSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [gameInfoView addSubview:headerSeparatorView];
    }
    
    return headerSeparatorView;
}


- (UIActivityIndicatorView *)activityIndicatorView {
    if (!activityIndicatorView) {
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        CGFloat midX = CGRectGetMidX(self.bounds);
        CGFloat midY = CGRectGetMidY(self.bounds);
        
        activityIndicatorView.center = CGPointMake(midX, midY);
        activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        activityIndicatorView.hidesWhenStopped = YES;
        [activityIndicatorView stopAnimating];
        
        [self addSubview:activityIndicatorView];
    }
    
    return activityIndicatorView;
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
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        headerView = [[MIGAGradientView alloc] initWithFrame:CGRectMake(0, 0, aFrame.size.width, 126.0f)];
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        
        gameInfoView = [[UIView alloc] initWithFrame:CGRectMake(headerView.bounds.size.height, 10.0f, headerView.bounds.size.width - headerView.bounds.size.height, 36.0f)];
        gameInfoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        
        gameInfoView.opaque = NO;
        gameInfoView.backgroundColor = [UIColor clearColor];
        self.headerSeparatorView.hidden = NO;
        [headerView addSubview:gameInfoView];

        
        contentView = [[MIGAGradientView alloc] initWithFrame:CGRectMake(0, 126.0f, aFrame.size.width, aFrame.size.height - 126.0f)];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:headerView];
        [self addSubview:contentView];
        
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
    
    headerView.colors = gradientColors;
            
    gradientColors = [NSArray arrayWithObjects:
                      (id)[[UIColor blackColor] CGColor],
                      nil];
    
    contentView.colors = gradientColors;
}


- (void)dealloc {
    [tapTarget release];
    
    [titleLabel release];
    [publisherLabel release];
    [detailLabel release];
    [iconImageView release];
    [screenshotImageView release];

    [activityIndicatorView release];
    
    [headerSeparatorView release];
    [headerView release];
    [contentView release];
    [gameInfoView release];
    
    [reuseIdentifier release];
    
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
    if (!activityIndicatorView)
        return;
    
    [self.activityIndicatorView stopAnimating];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self doTap:nil];
}


- (IBAction)doTap:(id)sender {
    if (tapTarget && tapSelector && [tapTarget respondsToSelector:tapSelector]) {
        [tapTarget performSelector:tapSelector withObject:self];
    }
}


@end
