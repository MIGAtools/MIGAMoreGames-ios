//
//  MIGAApplicationInfo.m
//  MIGAMoreGames
//
//  Created by Darryl H. Thomas on 7/24/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "MIGALogging.h"
#import "MIGAApplicationInfo.h"
#import "UIColor+MIGAExtensions.h"
#import "MIGAURL.h"

NSString * const kMIGAApplicationInfoIconImageType = @"icon";
NSString * const kMIGAApplicationInfoScreenshotImageType = @"screenshot";

NSString * const kMIGAApplicationInfoContentIdKey = @"content_id";
NSString * const kMIGAApplicationInfoPackageKey = @"package";
NSString * const kMIGAApplicationInfoTitleKey = @"title";
NSString * const kMIGAApplicationInfoPublisherKey = @"publisher";
NSString * const kMIGAApplicationInfoClickURLStringKey = @"click_url";
NSString * const kMIGAApplicationInfoPriceKey = @"price";
NSString * const kMIGAApplicationInfoDetailKey = @"detail";
NSString * const kMIGAApplicationInfoImagesKey = @"images";
NSString * const kMIGAApplicationInfoBackgroundColorStringKey = @"background_color";

@implementation MIGAApplicationInfo
@synthesize contentId;
@synthesize package;
@synthesize title;
@synthesize publisher;
@synthesize clickURLString;
@synthesize price;
@synthesize detail;
@synthesize backgroundColor;
@synthesize images;

#pragma mark -
#pragma mark Instance Methods

- (id)initWithContentsOfDictionary:(NSDictionary *)dictionary {
    if ((self = [self init])) {
        self.contentId = [[dictionary objectForKey:kMIGAApplicationInfoContentIdKey] intValue];
        self.package = [dictionary objectForKey:kMIGAApplicationInfoPackageKey];
        self.title = [dictionary objectForKey:kMIGAApplicationInfoTitleKey];
        self.publisher = [dictionary objectForKey:kMIGAApplicationInfoPublisherKey];
        self.clickURLString = [dictionary objectForKey:kMIGAApplicationInfoClickURLStringKey];
        self.price = [dictionary objectForKey:kMIGAApplicationInfoPriceKey];
        self.detail = [dictionary objectForKey:kMIGAApplicationInfoDetailKey];
        NSString *backgroundColorString = [dictionary objectForKey:kMIGAApplicationInfoBackgroundColorStringKey];
        if (backgroundColorString) {
            self.backgroundColor = [UIColor migaColorWithHexString:backgroundColorString ignoreAlphaComponent:YES];
        } else {
            self.backgroundColor = [UIColor blackColor];
        }
        
        id imagesObject = [dictionary objectForKey:kMIGAApplicationInfoImagesKey];
        if ([imagesObject isKindOfClass:[NSDictionary class]]) {
            self.images = [dictionary objectForKey:kMIGAApplicationInfoImagesKey];
        } else {
            self.images = nil;
        }
    }
    
    return self;
}


- (void)dealloc {
    [package release];
    [title release];
    [publisher release];
    [clickURLString release];
    [price release];
    [detail release];
    [backgroundColor release];
    [images release];

    [super dealloc];
}


- (NSDictionary *)dictionaryValue {
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithUnsignedInt: self.contentId], kMIGAApplicationInfoContentIdKey,
                            self.package, kMIGAApplicationInfoPackageKey,
                            self.title, kMIGAApplicationInfoTitleKey,
                            self.publisher, kMIGAApplicationInfoPublisherKey,
                            self.clickURLString, kMIGAApplicationInfoClickURLStringKey,
                            self.price, kMIGAApplicationInfoPriceKey,
                            self.detail, kMIGAApplicationInfoDetailKey,
                            [self.backgroundColor migaHexString], kMIGAApplicationInfoBackgroundColorStringKey,
                            self.images, kMIGAApplicationInfoImagesKey,
                            nil];
    
    return result;
}


- (NSURL *)imageURLForType:(NSString *)typeKey size:(CGSize)size contentScale:(CGFloat)contentScale actualScale:(CGFloat *)actualScale {
    static NSString * const imageURLKeyFormatString = @"%@-%dx%d";
    NSString *matchedURLString = nil;
    CGFloat scale = *actualScale = contentScale;
    
    while ((matchedURLString == nil) && (scale > 0)) {
        NSString *imageURLKey = [NSString stringWithFormat:imageURLKeyFormatString, typeKey, (int)floorf(size.width * scale), (int)floorf(size.height * scale)];
        
        //MIGADLog(@"Attempting to match image url for %.02f scale with key: %@", scale, imageURLKey);
        
        if (!(matchedURLString = [self.images objectForKey:imageURLKey])) {
            if ((scale < 1.0f) && (scale > 0.0f)) {
                scale = 1.0f;
            } else {
                CGFloat scaleFloor = floorf(scale);
                scale = (scaleFloor != scale) ? scaleFloor : scale - 1;
            }
        }
    }
    
    if (!matchedURLString)
        return nil;
    
    //MIGADLog(@"Best image url match: %@, scale: %.02f", matchedURLString, scale);
    *actualScale = scale;
    return [MIGAURL URLWithString:matchedURLString];
}


- (NSURL *)imageURLForType:(NSString *)typeKey size:(CGSize)size {
    return [self imageURLForType:typeKey size:size contentScale:1.0f actualScale:NULL];
}


@end
