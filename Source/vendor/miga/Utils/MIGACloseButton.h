//
//  MIGACloseButton.h
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/11/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CAShapeLayer;

@interface MIGACloseButton : UIControl {
    @private
    CAShapeLayer *_borderLayer;
    CAShapeLayer *_glyphLayer;
}

@property (nonatomic,retain,readonly) CAShapeLayer *layer;

@end
