//
//  MIGAApplicationInfo.h
//  MIGAMoreGames
//
//  Created by Darryl H. Thomas on 7/24/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kMIGAApplicationInfoIconImageType;
extern NSString * const kMIGAApplicationInfoScreenshotImageType;

extern NSString * const kMIGAApplicationInfoContentIdKey;
extern NSString * const kMIGAApplicationInfoPackageKey;
extern NSString * const kMIGAApplicationInfoTitleKey;
extern NSString * const kMIGAApplicationInfoPublisherKey;
extern NSString * const kMIGAApplicationInfoClickURLStringKey;
extern NSString * const kMIGAApplicationInfoPriceKey;
extern NSString * const kMIGAApplicationInfoDetailKey;
extern NSString * const kMIGAApplicationInfoImagesKey;
extern NSString * const kMIGAApplicationInfoBackgroundColorStringKey;

@interface MIGAApplicationInfo : NSObject {
	@private
	NSUInteger contentId;
	NSString *package;
	NSString *title;
	NSString *publisher;
	NSString *clickURLString;
	NSString *price;
	NSString *detail;
	UIColor *backgroundColor;
	
	NSDictionary *images;
}

@property (nonatomic, assign) NSUInteger contentId;
@property (nonatomic, retain) NSString *package;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *publisher;
@property (nonatomic, retain) NSString *clickURLString;
@property (nonatomic, retain) NSString *price;
@property (nonatomic, retain) NSString *detail;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) NSDictionary *images;

-(id)initWithContentsOfDictionary: (NSDictionary *)dictionary;

-(NSDictionary *)dictionaryValue;

-(NSURL *)imageURLForType: (NSString *)typeKey size: (CGSize)size contentScale: (CGFloat)contentScale actualScale: (CGFloat *)actualScale;
-(NSURL *)imageURLForType:(NSString *)typeKey size:(CGSize)size;

@end
