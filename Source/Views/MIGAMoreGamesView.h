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
-(void)migaMoreGamesView: (MIGAMoreGamesView *)moreGamesView didScrollToPage: (NSUInteger)page;
@end


@protocol MIGAMoreGamesViewDataSource <NSObject>

@required

-(NSUInteger)numberOfApplicationsInMoreGamesView: (MIGAMoreGamesView *)moreGamesView;
-(MIGAMoreGamesViewCell *)migaMoreGamesView: (MIGAMoreGamesView *)moreGamesView cellForApplicationAtIndex: (NSUInteger)index;

@optional

@end


@interface MIGAMoreGamesView : UIScrollView <UIScrollViewDelegate> {
	@private
	id<MIGAMoreGamesViewDataSource> dataSource;
	id<MIGAMoreGamesViewDelegate> moreGamesViewDelegate;
	id<MIGAMoreGamesViewCellLayoutManager> cellLayoutManager;
	
	NSUInteger applicationCount;
	
	BOOL layoutIsDirty;
	UIInterfaceOrientation interfaceOrientation;
	
	NSUInteger currentPage;
	BOOL explicitlySettingPage;
	
	NSRange usedCellsRange;
	
	NSMutableArray * usedCells;
	NSMutableDictionary * reusableCells;
}

@property (nonatomic, retain) IBOutlet id<MIGAMoreGamesViewDataSource> dataSource;
@property (nonatomic, retain) IBOutlet id<MIGAMoreGamesViewDelegate> moreGamesViewDelegate;
@property (nonatomic, retain) IBOutlet id<MIGAMoreGamesViewCellLayoutManager> cellLayoutManager;

@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

@property (nonatomic, assign) NSUInteger currentPage;

-(void)reloadData;
-(MIGAMoreGamesViewCell *)dequeueReusableCellWithIdentifier: (NSString *)identifier;

-(void)layoutCellsForInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation;
-(void)layoutCellsForInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration: (NSTimeInterval)duration;

@end
