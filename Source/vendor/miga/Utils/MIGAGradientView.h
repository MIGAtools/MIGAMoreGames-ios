//
//  MIGAGradientView.h
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/7/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/*!
 @class MIGAGradientView
 
 @abstract A subclass of UIView which sets its layerClass as CAGradientLayer
 
 @discussion MIGAGradientView is a simple subclass of UIView which introduces no
 additional functionailty other than overriding the class of the backing layer
 to CAGradientLayer and exposing proxy properties for the gradient layer.
 
 The benefit of using MIGAGradientView instead of adding a CAGradientLayer sublayer
 to a view is that, as the view's backing layer, the gradient layer will be resized
 appropriately when the bounds/frame of the view changes without additional code.
 */
@interface MIGAGradientView : UIView {

}

@property (nonatomic,retain,readonly) CAGradientLayer *layer;

// Pass-through properties (proxied to CAGradientLayer)
@property (copy) NSArray *colors;
@property(copy) NSArray *locations;
@property CGPoint startPoint, endPoint;
@property(copy) NSString *type;

@end
