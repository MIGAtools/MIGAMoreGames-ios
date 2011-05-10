//
//  MIGACloseButton.m
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/11/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "MIGACloseButton.h"

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
        
        borderLayer.path = path;
        CGPathRelease(path);
        
        self.layer.fillColor = [[UIColor darkGrayColor] CGColor];
        borderLayer.strokeColor = [[UIColor whiteColor] CGColor];
        borderLayer.lineWidth = 2.0f;

        if (layersSupportShadowProperties) {
            borderLayer.shadowColor = [[UIColor blackColor] CGColor];
            borderLayer.shadowOpacity = 1.0f;
            borderLayer.shadowOffset = CGSizeMake(0.0, 2.0f);
            borderLayer.shadowRadius = 2.0f;
        }
        
        borderLayer.fillColor = nil;
        

        glyphLayer = [CAShapeLayer layer];
        CGRect glyphRect = CGRectInset(self.layer.bounds, 4.0f, 4.0f);
        path = CGPathCreateMutable();
        
        CGPathMoveToPoint(path, NULL, CGRectGetMidX(glyphRect), CGRectGetMinY(glyphRect));
        CGPathAddLineToPoint(path, NULL, CGRectGetMidX(glyphRect), CGRectGetMaxY(glyphRect));
        CGPathMoveToPoint(path, NULL, CGRectGetMinX(glyphRect), CGRectGetMidY(glyphRect));
        CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(glyphRect), CGRectGetMidY(glyphRect));
        glyphLayer.frame = self.layer.bounds;
        glyphLayer.path = path;
        CGPathRelease(path);
        
        glyphLayer.strokeColor = [[UIColor whiteColor] CGColor];
        glyphLayer.fillColor = nil;
        glyphLayer.lineWidth = 2.0f;

        if (layersSupportShadowProperties) {
            glyphLayer.shadowOpacity = 1.0f;
            glyphLayer.shadowColor = [[UIColor blackColor] CGColor];
            glyphLayer.shadowOffset = CGSizeMake(0.0, 2.0f);
            glyphLayer.shadowRadius = 2.0f;
        }
        
        glyphLayer.transform = CATransform3DMakeRotation(M_PI / 4.0f, 0, 0, 1.0f);


        [self.layer addSublayer:[CALayer layer]];
        [self.layer addSublayer:borderLayer];
        [self.layer addSublayer:glyphLayer];
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
