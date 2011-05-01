//
//  MIGACloseButton.h
//  MIGAUtils
//
//  Created by Darryl H. Thomas on 8/11/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MIGACloseButton : UIControl {
	@private
	CAShapeLayer *borderLayer;
	CAShapeLayer *glyphLayer;
}

@property (nonatomic, retain, readonly) CAShapeLayer *layer;

@end
