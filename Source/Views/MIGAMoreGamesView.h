//
//  MIGAMoreGamesView.h
//  MIGAMoreGames
//
//  Created by Darryl H. Thomas on 7/24/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIGAMoreGamesViewCell.h"

@class MIGAMoreGamesView;

@protocol MIGAMoreGamesViewDelegate <NSObject>
@optional
- (void)migaMoreGamesView:(MIGAMoreGamesView *)moreGamesView didScrollToPage:(NSUInteger)page;
@end


@protocol MIGAMoreGamesViewDataSource <NSObject>

@required

- (NSUInteger)numberOfApplicationsInMoreGamesView:(MIGAMoreGamesView *)moreGamesView;
- (MIGAMoreGamesViewCell *)migaMoreGamesView:(MIGAMoreGamesView *)moreGamesView cellForApplicationAtIndex:(NSUInteger)index;

@optional

@end


@interface MIGAMoreGamesView : UIScrollView <UIScrollViewDelegate> {
    @private
    id<MIGAMoreGamesViewDataSource> _dataSource;
    id<MIGAMoreGamesViewDelegate> _moreGamesViewDelegate;
    id<MIGAMoreGamesViewCellLayoutManager> _cellLayoutManager;
    
    NSUInteger _applicationCount;
    
    BOOL _layoutIsDirty;
    UIInterfaceOrientation _interfaceOrientation;
    
    NSUInteger _currentPage;
    BOOL _explicitlySettingPage;
    
    NSRange _usedCellsRange;
    
    NSMutableArray *_usedCells;
    NSMutableDictionary *_reusableCells;
}

@property (nonatomic,retain) IBOutlet id<MIGAMoreGamesViewDataSource> dataSource;
@property (nonatomic,retain) IBOutlet id<MIGAMoreGamesViewDelegate> moreGamesViewDelegate;
@property (nonatomic,retain) IBOutlet id<MIGAMoreGamesViewCellLayoutManager> cellLayoutManager;

@property (nonatomic,assign) UIInterfaceOrientation interfaceOrientation;

@property (nonatomic,assign) NSUInteger currentPage;

- (void)reloadData;
- (MIGAMoreGamesViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)layoutCellsForInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)layoutCellsForInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

@end
