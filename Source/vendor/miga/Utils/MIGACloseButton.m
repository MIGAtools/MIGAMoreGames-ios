//
//  MIGACloseButton.m
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/11/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "MIGACloseButton.h"
#import <QuartzCore/QuartzCore.h>
#import "MIGAAvailability.h"

@implementation MIGACloseButton
@dynamic layer;

+ (Class)layerClass {
    return [CAShapeLayer class];
}


- (id)initWithFrame:(CGRect)aFrame {
    if ((self = [super initWithFrame:aFrame])) {
        self.accessibilityTraits = UIAccessibilityTraitButton;
        self.accessibilityLabel = NSLocalizedString(@"Done", @"");
        
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.frame = self.layer.bounds;
        
        BOOL layersSupportShadowProperties = [self.layer respondsToSelector:@selector(setShadowPath:)];
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddEllipseInRect(path, NULL, self.layer.bounds);
        self.layer.path = path;
        
        if (layersSupportShadowProperties) {
            self.layer.shadowPath = path;
        }
        
        _borderLayer.path = path;
        CGPathRelease(path);
        
        self.layer.fillColor = [[UIColor darkGrayColor] CGColor];
        _borderLayer.strokeColor = [[UIColor whiteColor] CGColor];
        _borderLayer.lineWidth = 2.0f;

        if (layersSupportShadowProperties) {
            _borderLayer.shadowColor = [[UIColor blackColor] CGColor];
            _borderLayer.shadowOpacity = 1.0f;
            _borderLayer.shadowOffset = CGSizeMake(0.0, 2.0f);
            _borderLayer.shadowRadius = 2.0f;
        }
        
        _borderLayer.fillColor = nil;
        

        _glyphLayer = [CAShapeLayer layer];
        CGRect glyphRect = CGRectInset(self.layer.bounds, 4.0f, 4.0f);
        path = CGPathCreateMutable();
        
        CGPathMoveToPoint(path, NULL, CGRectGetMidX(glyphRect), CGRectGetMinY(glyphRect));
        CGPathAddLineToPoint(path, NULL, CGRectGetMidX(glyphRect), CGRectGetMaxY(glyphRect));
        CGPathMoveToPoint(path, NULL, CGRectGetMinX(glyphRect), CGRectGetMidY(glyphRect));
        CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(glyphRect), CGRectGetMidY(glyphRect));
        _glyphLayer.frame = self.layer.bounds;
        _glyphLayer.path = path;
        CGPathRelease(path);
        
        _glyphLayer.strokeColor = [[UIColor whiteColor] CGColor];
        _glyphLayer.fillColor = nil;
        _glyphLayer.lineWidth = 2.0f;

        if (layersSupportShadowProperties) {
            _glyphLayer.shadowOpacity = 1.0f;
            _glyphLayer.shadowColor = [[UIColor blackColor] CGColor];
            _glyphLayer.shadowOffset = CGSizeMake(0.0, 2.0f);
            _glyphLayer.shadowRadius = 2.0f;
        }
        
        _glyphLayer.transform = CATransform3DMakeRotation(M_PI / 4.0f, 0, 0, 1.0f);

#if MIGA_IOS_4_0_SUPPORTED
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            CGFloat screenScale = [[UIScreen mainScreen] scale];
            self.layer.contentsScale = screenScale;
            _borderLayer.contentsScale = screenScale;
            _glyphLayer.contentsScale = screenScale;
        }
#endif
        
        [self.layer addSublayer:[CALayer layer]];
        [self.layer addSublayer:_borderLayer];
        [self.layer addSublayer:_glyphLayer];
    }
    
    return self;
}


- (void)dealloc {
    [super dealloc];
}

- (BOOL)isAccessibilityElement {
    return YES;
}


@end
