//
//  MIGAMoreGamesView.m
//  MIGAMoreGames
//
//  Created by Darryl H. Thomas on 7/24/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "MIGALogging.h"
#import "MIGAMoreGamesView.h"
#import "MIGAMoreGamesViewCell.h"

@interface MIGAMoreGamesView ()

@property (nonatomic, retain) NSMutableArray * usedCells;
@property (nonatomic, retain) NSMutableDictionary * reusableCells;

-(void)commonInit;

-(MIGAMoreGamesViewCell *)addCellForIndex: (NSUInteger)index;
-(CGRect)cellRectAtIndex: (NSUInteger)index;
-(void)enqueueReusableCells: (NSArray *)cells;
-(NSIndexSet *)indicesOfCellsInRect: (CGRect)rect;
-(void)layoutCellsInVisibleRange: (NSRange)range;
-(CGSize)requiredContentSize;
-(void)updateVisibleCells;
-(CGRect)visibleContentBounds;
-(void)layoutCellUsingCellManager: (MIGAMoreGamesViewCell *)cell withInterfaceOrientation: (UIInterfaceOrientation)orientation;

@end

@implementation MIGAMoreGamesView

#pragma mark -
#pragma mark Properties

@synthesize usedCells, reusableCells;
@synthesize dataSource, moreGamesViewDelegate;
@synthesize cellLayoutManager;
@synthesize interfaceOrientation;

-(void)setCurrentPage:(NSUInteger)page;
{
	explicitlySettingPage = YES;
	currentPage = page % applicationCount;
	[self scrollRectToVisible: [self cellRectAtIndex: currentPage] animated: YES];
}

-(NSUInteger)currentPage;
{
	return currentPage;
}

-(NSMutableArray *)usedCells;
{
	if (!usedCells) {
		usedCells = [[NSMutableArray alloc] initWithCapacity: applicationCount];
	}
	
	return usedCells;
}

-(NSMutableDictionary *)reusableCells;
{
	if (!reusableCells) {
		reusableCells = [[NSMutableDictionary alloc] init];
	}
	
	return reusableCells;
}

-(void)setFrame:(CGRect)aFrame;
{
	if (CGRectEqualToRect(self.frame, aFrame))
		return;
	
	[super setFrame: aFrame];
	
	self.contentSize = [self requiredContentSize];
	layoutIsDirty = YES;

	[self setNeedsLayout];
}

-(void)setInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
	if (toInterfaceOrientation == interfaceOrientation)
		return;
	
	interfaceOrientation = toInterfaceOrientation;
	[self setNeedsLayout];
	[self setNeedsDisplay];
	[self.reusableCells removeAllObjects];
	//[self layoutCellsForInterfaceOrientation: interfaceOrientation];
}

#pragma mark -
#pragma mark Instance Methods

-(id)initWithCoder:(NSCoder *)aDecoder;
{
	if ((self = [super initWithCoder: aDecoder])) {
		[self commonInit];
	}
	
	return self;
}

-(id)initWithFrame:(CGRect)aFrame;
{
	if ((self = [super initWithFrame: aFrame])) {
		[self commonInit];
	}
	
	return self;
}

-(void)commonInit;
{
	self.delegate = self;
	
	self.showsVerticalScrollIndicator = NO;
	self.showsHorizontalScrollIndicator = NO;
	
	self.backgroundColor = [UIColor blackColor];
	usedCellsRange = NSMakeRange(0, 0);
	currentPage = 0;
	self.pagingEnabled = YES;
}

-(void)dealloc;
{
	[usedCells release];
	[reusableCells release];
	[cellLayoutManager release];
	
	[super dealloc];
}

-(CGRect)visibleContentBounds;
{
	CGRect result = CGRectZero;
	result.origin = self.contentOffset;
	result.size = self.bounds.size;
	
	return result;
}

-(MIGAMoreGamesViewCell *)addCellForIndex: (NSUInteger)index;
{
	BOOL animationsWereEnabled = [UIView areAnimationsEnabled];
	[UIView setAnimationsEnabled: NO];
	
	MIGAMoreGamesViewCell *result = [self.dataSource migaMoreGamesView: self cellForApplicationAtIndex: index];
	
	result.frame = [self cellRectAtIndex: index];
	[self insertSubview: result atIndex: 0];
	
	if (animationsWereEnabled) {
		[UIView setAnimationsEnabled: YES];
	}
	
	return result;
}

-(CGRect)cellRectAtIndex: (NSUInteger)index;
{
	CGRect result = self.bounds;
	result.origin.x = result.size.width * index;
	
	return result;
}

-(MIGAMoreGamesViewCell *)dequeueReusableCellWithIdentifier: (NSString *)identifier;
{
	NSMutableArray *reusableCellsWithIdentifier = [self.reusableCells objectForKey: identifier];
	
	if (!reusableCellsWithIdentifier || ([reusableCellsWithIdentifier count] < 1))
		return nil;
	
	MIGAMoreGamesViewCell *result = [[reusableCellsWithIdentifier lastObject] retain];
	[reusableCellsWithIdentifier removeLastObject];
	
	[result prepareForReuse];
	return [result autorelease];
}

-(void)enqueueReusableCells:(NSArray *)cells;
{
	for (MIGAMoreGamesViewCell *cell in cells) {
		NSMutableArray * reusableCellsWithIdentifier = [self.reusableCells objectForKey: cell.reuseIdentifier];
		if (!reusableCellsWithIdentifier) {
			reusableCellsWithIdentifier = [[[NSMutableArray alloc] init] autorelease];
			[self.reusableCells setObject: reusableCellsWithIdentifier forKey: cell.reuseIdentifier];
		}
		
		[reusableCellsWithIdentifier addObject: cell];
	}
}

-(NSIndexSet *)indicesOfCellsInRect: (CGRect)rect;
{
	NSMutableIndexSet *result = [[NSMutableIndexSet alloc] init];
	
	for (NSUInteger i = 0; i < applicationCount; i++) {
		CGRect cellRect = [self cellRectAtIndex: i];
		
		if (CGRectIntersectsRect(cellRect, rect)) {
			[result addIndex: i];
		}
		
		if (CGRectGetMaxX(cellRect) > CGRectGetMaxX(rect)) {
			break;
		}
	}
	
	return [result autorelease];
}

-(void)layoutSubviews;
{
	[super layoutSubviews];
	
	if (!CGRectIsEmpty([self visibleContentBounds])) {
		[self updateVisibleCells];
	}
}

-(void)layoutCellsInVisibleRange: (NSRange)range;
{
}

-(void)reloadData;
{
	applicationCount = [self.dataSource numberOfApplicationsInMoreGamesView: self];
	self.contentSize = [self requiredContentSize];
	
	currentPage = 0;
	
	[self.usedCells makeObjectsPerformSelector: @selector(removeFromSuperview)];
	[self enqueueReusableCells: self.usedCells];
	[self.usedCells removeAllObjects];
	usedCellsRange = NSMakeRange(0, 0);
	
	if (applicationCount > 0) {
		[self updateVisibleCells];
	}
	
	[self setNeedsLayout];
	[self scrollRectToVisible: CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) animated: NO];
	
	if (moreGamesViewDelegate && [moreGamesViewDelegate respondsToSelector: @selector(migaMoreGamesView:didScrollToPage:)]) {
		[moreGamesViewDelegate migaMoreGamesView: self didScrollToPage: currentPage];
	}
}

-(CGSize)requiredContentSize;
{
	CGSize result = self.bounds.size;
	result.width *= applicationCount;
	
	return result;
}

-(void)updateVisibleCells;
{
	NSIndexSet *newVisibleIndices = [self indicesOfCellsInRect: [self visibleContentBounds]];
	
	NSUInteger beforeTest = (usedCellsRange.location == 0 ? NSNotFound : usedCellsRange.location - 1);
	NSUInteger afterTest = MIN(usedCellsRange.location + usedCellsRange.length, applicationCount);
	
	if ([newVisibleIndices countOfIndexesInRange: usedCellsRange] < usedCellsRange.length) {
		NSMutableIndexSet *indicesToRemove = [[NSMutableIndexSet alloc] initWithIndexesInRange: usedCellsRange];
		[indicesToRemove removeIndexes: newVisibleIndices];
		
		BOOL contiguous = (([indicesToRemove lastIndex] - [indicesToRemove firstIndex] - 1) == [indicesToRemove count]);
		
		if (contiguous) {
			BOOL removeFromFront = [indicesToRemove containsIndex: usedCellsRange.location];
			
			NSUInteger toRemoveCount = [indicesToRemove count];
			NSRange removalRange = removeFromFront ? NSMakeRange(0, toRemoveCount) : NSMakeRange([usedCells count] - toRemoveCount, toRemoveCount);
			
			NSMutableArray * removedCells = [[usedCells subarrayWithRange: removalRange] mutableCopy];
			
			[usedCells removeObjectsInRange: removalRange];
			usedCellsRange.length -= toRemoveCount;
			
			if (removeFromFront) {
				usedCellsRange.location += toRemoveCount;
			}
			
			[removedCells makeObjectsPerformSelector: @selector(removeFromSuperview)];
			[self enqueueReusableCells: removedCells];
			[removedCells release];
		} else {
			
			NSMutableArray * removedCells = [usedCells mutableCopy];
			
			[usedCells removeObjectsInArray: removedCells];
			[removedCells makeObjectsPerformSelector: @selector(removeFromSuperview)];
			
			[self enqueueReusableCells: removedCells];
			
			usedCellsRange.location = [newVisibleIndices firstIndex];
			usedCellsRange.length = [newVisibleIndices count];
			
			NSUInteger i = [newVisibleIndices firstIndex];
			while (i != NSNotFound) {
				MIGAMoreGamesViewCell *cell = [self addCellForIndex: i];
				[usedCells addObject: cell];
				
				i = [newVisibleIndices indexGreaterThanIndex: i];
			}
			
			[self layoutCellsInVisibleRange: NSMakeRange(0, [usedCells count])];
			
			[removedCells release];
		}

		[indicesToRemove release];
	}
	
	BOOL wereAnimationsEnabled = [UIView areAnimationsEnabled];
	[UIView setAnimationsEnabled: NO];
	
	if ((beforeTest != NSNotFound) && ([newVisibleIndices containsIndex: beforeTest])) {
		NSMutableIndexSet * newIndices = [newVisibleIndices mutableCopy];
		[newIndices removeIndexesInRange: usedCellsRange];
		
		NSUInteger i = [newIndices lastIndex];
		while (i != NSNotFound) {
			MIGAMoreGamesViewCell *cell = [self addCellForIndex: i];
			[usedCells insertObject: cell atIndex: 0];
			
			i = [newIndices indexLessThanIndex: i];
		}
		
		usedCellsRange.length += [newIndices count];
		usedCellsRange.location = [newVisibleIndices firstIndex];
		
		NSRange newCellRange = NSMakeRange([newIndices firstIndex],  ([newIndices lastIndex] - [newIndices firstIndex]) + 1);
		newCellRange.location = MIN(0, newCellRange.location - usedCellsRange.location);
		
		[self layoutCellsInVisibleRange: newCellRange];
		
		[newIndices release];
		
	} else if ((NSLocationInRange(afterTest, usedCellsRange) == NO) && ([newVisibleIndices containsIndex: afterTest])) {
		
		NSMutableIndexSet * newIndices = [newVisibleIndices mutableCopy];
		[newIndices removeIndexesInRange: usedCellsRange];
		
		NSUInteger i = [newIndices firstIndex];
		while (i != NSNotFound) {
			MIGAMoreGamesViewCell *cell = [self addCellForIndex: i];
			[usedCells addObject: cell];
			
			i = [newIndices indexGreaterThanIndex: i];
		}
		
		usedCellsRange.length += [newIndices count];
		usedCellsRange.location = [newVisibleIndices firstIndex];
		
		NSRange newCellRange = NSMakeRange([newIndices firstIndex],  ([newIndices lastIndex] - [newIndices firstIndex]) + 1);
		newCellRange.location -= usedCellsRange.location;
		
		[self layoutCellsInVisibleRange: newCellRange];
		
		[newIndices release];
	}

	[self layoutCellsInVisibleRange: usedCellsRange];
	if (wereAnimationsEnabled) {
		[UIView setAnimationsEnabled: YES];
	}
}

-(void)layoutCellUsingCellManager: (MIGAMoreGamesViewCell *)cell withInterfaceOrientation: (UIInterfaceOrientation)orientation;
{
	if (!cellLayoutManager)
		return;

	[cellLayoutManager performLayoutForCell: cell withInterfaceOrientation: orientation];
}

-(void)layoutCellsForInterfaceOrientation: (UIInterfaceOrientation)orientation;
{
	[self layoutCellsForInterfaceOrientation: orientation duration: 0];
}

-(void)layoutCellsForInterfaceOrientation: (UIInterfaceOrientation)orientation duration: (NSTimeInterval)duration;
{
	[UIView beginAnimations: @"MIGAMoreGamesViewOrientationChange" context: NULL];
	[UIView setAnimationDuration: duration];
	for (MIGAMoreGamesViewCell *cell in self.usedCells) {
		[self layoutCellUsingCellManager: cell withInterfaceOrientation: orientation];
	}
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
	if (explicitlySettingPage) {
		return;
	}
	
	CGRect cellRect = [self cellRectAtIndex: 0];
	CGFloat pageWidth = cellRect.size.width;
	
	NSUInteger newPage = (NSUInteger)(floor((self.contentOffset.x - pageWidth / 2.0) / pageWidth) + 1);

	if (newPage != currentPage) {
		currentPage = newPage;
		if (moreGamesViewDelegate && [moreGamesViewDelegate respondsToSelector: @selector(migaMoreGamesView:didScrollToPage:)]) {
			[moreGamesViewDelegate migaMoreGamesView: self didScrollToPage: currentPage];
		}
	}
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
	explicitlySettingPage = NO;
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
{
	explicitlySettingPage = NO;
}

@end
