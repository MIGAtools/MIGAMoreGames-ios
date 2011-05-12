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

@property (nonatomic,retain) NSMutableArray *usedCells;
@property (nonatomic,retain) NSMutableDictionary *reusableCells;

- (void)commonInit;

- (MIGAMoreGamesViewCell *)addCellForIndex:(NSUInteger)index;
- (CGRect)cellRectAtIndex:(NSUInteger)index;
- (void)enqueueReusableCells:(NSArray *)cells;
- (NSIndexSet *)indicesOfCellsInRect:(CGRect)rect;
- (void)layoutCellsInVisibleRange:(NSRange)range;
- (CGSize)requiredContentSize;
- (void)updateVisibleCells;
- (CGRect)visibleContentBounds;
- (void)layoutCellUsingCellManager:(MIGAMoreGamesViewCell *)cell withInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end

@implementation MIGAMoreGamesView

#pragma mark -
#pragma mark Properties

@synthesize usedCells=_usedCells;
@synthesize reusableCells=_reusableCells;
@synthesize dataSource=_dataSource;
@synthesize moreGamesViewDelegate=_moreGamesViewDelegate;
@synthesize cellLayoutManager=_cellLayoutManager;

- (void)setMoreGamesViewDelegate:(id<MIGAMoreGamesViewDelegate>)moreGamesViewDelegate {
    _moreGamesViewDelegate = moreGamesViewDelegate;
    _delegateRespondsTo.didScrollToPage = [_moreGamesViewDelegate respondsToSelector:@selector(migaMoreGamesView:didScrollToPage:)];
}

- (void)setCurrentPage:(NSUInteger)page {
    _explicitlySettingPage = YES;
    _currentPage = page % _applicationCount;
    [self scrollRectToVisible:[self cellRectAtIndex:_currentPage] animated:YES];
}


- (NSUInteger)currentPage {
    return _currentPage;
}


- (NSMutableArray *)usedCells {
    if (!_usedCells) {
        _usedCells = [[NSMutableArray alloc] initWithCapacity:_applicationCount];
    }
    
    return _usedCells;
}


- (NSMutableDictionary *)reusableCells {
    if (!_reusableCells) {
        _reusableCells = [[NSMutableDictionary alloc] init];
    }
    
    return _reusableCells;
}


- (void)setFrame:(CGRect)aFrame {
    if (CGRectEqualToRect(self.frame, aFrame))
        return;
    
    _explicitlySettingPage = YES;
    [super setFrame:aFrame];
    
    self.contentSize = [self requiredContentSize];
    [self scrollRectToVisible:[self cellRectAtIndex:_currentPage] animated:NO];
    _explicitlySettingPage = NO;
    [self setNeedsLayout];
}


#pragma mark -
#pragma mark Instance Methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    
    return self;
}


- (id)initWithFrame:(CGRect)aFrame {
    if ((self = [super initWithFrame:aFrame])) {
        [self commonInit];
    }
    
    return self;
}


- (void)commonInit {
    self.delegate = self;
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    self.backgroundColor = [UIColor blackColor];
    _usedCellsRange = NSMakeRange(0, 0);
    _currentPage = 0;
    self.pagingEnabled = YES;
    self.opaque = YES;
}


- (void)dealloc {
    [_usedCells release];
    [_reusableCells release];
    [_cellLayoutManager release];
    
    [super dealloc];
}


- (CGRect)visibleContentBounds {
    CGRect result = CGRectZero;
    result.origin = self.contentOffset;
    result.size = self.bounds.size;
    
    return result;
}


- (MIGAMoreGamesViewCell *)addCellForIndex:(NSUInteger)index {
    BOOL animationsWereEnabled = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
    
    MIGAMoreGamesViewCell *result = [self.dataSource migaMoreGamesView:self cellForApplicationAtIndex:index];
    
    result.frame = [self cellRectAtIndex:index];
    [self insertSubview:result atIndex:0];
    
    if (animationsWereEnabled) {
        [UIView setAnimationsEnabled:YES];
    }
    
    return result;
}


- (CGRect)cellRectAtIndex:(NSUInteger)index {
    CGRect result = self.bounds;
    result.origin.x = result.size.width * index;
    
    return result;
}


- (MIGAMoreGamesViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    NSMutableArray *reusableCellsWithIdentifier = [self.reusableCells objectForKey:identifier];
    
    if (!reusableCellsWithIdentifier || ([reusableCellsWithIdentifier count] < 1))
        return nil;
    
    MIGAMoreGamesViewCell *result = [[reusableCellsWithIdentifier lastObject] retain];
    [reusableCellsWithIdentifier removeLastObject];
    
    [result prepareForReuse];
    return [result autorelease];
}


- (void)enqueueReusableCells:(NSArray *)cells {
    for (MIGAMoreGamesViewCell *cell in cells) {
        NSMutableArray *reusableCellsWithIdentifier = [self.reusableCells objectForKey:cell.reuseIdentifier];
        if (!reusableCellsWithIdentifier) {
            reusableCellsWithIdentifier = [[[NSMutableArray alloc] init] autorelease];
            [self.reusableCells setObject:reusableCellsWithIdentifier forKey:cell.reuseIdentifier];
        }
        
        [reusableCellsWithIdentifier addObject:cell];
    }
}


- (NSIndexSet *)indicesOfCellsInRect:(CGRect)rect {
    NSMutableIndexSet *result = [[NSMutableIndexSet alloc] init];
    
    for (NSUInteger i = 0; i < _applicationCount; i++) {
        CGRect cellRect = [self cellRectAtIndex:i];
        
        if (CGRectIntersectsRect(cellRect, rect)) {
            [result addIndex:i];
        }
        
        if (CGRectGetMaxX(cellRect) > CGRectGetMaxX(rect)) {
            break;
        }
    }
    
    return [result autorelease];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!CGRectIsEmpty([self visibleContentBounds])) {
        [self updateVisibleCells];
    }
}


- (void)layoutCellsInVisibleRange:(NSRange)range {
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsValidInterfaceOrientation(deviceOrientation)) {
        orientation = (UIInterfaceOrientation)deviceOrientation;
    }
    
    for (NSUInteger i = 0; i < [self.usedCells count]; i++) {
        MIGAMoreGamesViewCell *cell = [self.usedCells objectAtIndex:i];

        cell.frame = [self cellRectAtIndex: i + _usedCellsRange.location];
        [self layoutCellUsingCellManager:cell withInterfaceOrientation:orientation];
    }
}


- (void)reloadData {
    _applicationCount = [self.dataSource numberOfApplicationsInMoreGamesView:self];
    self.contentSize = [self requiredContentSize];
    
    _currentPage = 0;
    
    [self.usedCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self enqueueReusableCells:self.usedCells];
    [self.usedCells removeAllObjects];
    _usedCellsRange = NSMakeRange(0, 0);
    
    if (_applicationCount > 0) {
        [self updateVisibleCells];
    }
    
    [self setNeedsLayout];
    [self scrollRectToVisible:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) animated:NO];
    
    if (_moreGamesViewDelegate && _delegateRespondsTo.didScrollToPage) {
        [_moreGamesViewDelegate migaMoreGamesView:self didScrollToPage:_currentPage];
    }
}


- (CGSize)requiredContentSize {
    CGSize result = self.bounds.size;
    result.width *= _applicationCount;
    
    return result;
}


- (void)updateVisibleCells {
    NSIndexSet *newVisibleIndices = [self indicesOfCellsInRect:[self visibleContentBounds]];

    NSUInteger beforeTest = (_usedCellsRange.location == 0 ? NSNotFound : _usedCellsRange.location - 1);
    NSUInteger afterTest = MIN(_usedCellsRange.location + _usedCellsRange.length, _applicationCount);
    
    if ([newVisibleIndices countOfIndexesInRange:_usedCellsRange] < _usedCellsRange.length) {
        NSMutableIndexSet *indicesToRemove = [[NSMutableIndexSet alloc] initWithIndexesInRange:_usedCellsRange];
        [indicesToRemove removeIndexes:newVisibleIndices];
        
        BOOL contiguous = (([indicesToRemove lastIndex] - [indicesToRemove firstIndex] - 1) == [indicesToRemove count]);
        
        if (contiguous) {
            BOOL removeFromFront = [indicesToRemove containsIndex:_usedCellsRange.location];
            
            NSUInteger toRemoveCount = [indicesToRemove count];
            NSRange removalRange = removeFromFront ? NSMakeRange(0, toRemoveCount) : NSMakeRange([_usedCells count] - toRemoveCount, toRemoveCount);
            
            NSMutableArray *removedCells = [[_usedCells subarrayWithRange:removalRange] mutableCopy];
            
            [_usedCells removeObjectsInRange:removalRange];
            _usedCellsRange.length -= toRemoveCount;
            
            if (removeFromFront) {
                _usedCellsRange.location += toRemoveCount;
            }
            
            [removedCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self enqueueReusableCells:removedCells];
            [removedCells release];
        } else {
            
            NSMutableArray *removedCells = [_usedCells mutableCopy];
            
            [_usedCells removeObjectsInArray:removedCells];
            [removedCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            [self enqueueReusableCells:removedCells];
            
            _usedCellsRange.location = [newVisibleIndices firstIndex];
            _usedCellsRange.length = [newVisibleIndices count];
            
            NSUInteger i = [newVisibleIndices firstIndex];
            while (i != NSNotFound) {
                MIGAMoreGamesViewCell *cell = [self addCellForIndex:i];
                [_usedCells addObject:cell];
                
                i = [newVisibleIndices indexGreaterThanIndex:i];
            }
            
            [self layoutCellsInVisibleRange:NSMakeRange(0, [_usedCells count])];
            
            [removedCells release];
        }

        [indicesToRemove release];
    }
    
    BOOL wereAnimationsEnabled = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
    
    if ((beforeTest != NSNotFound) && ([newVisibleIndices containsIndex:beforeTest])) {
        NSMutableIndexSet *newIndices = [newVisibleIndices mutableCopy];
        [newIndices removeIndexesInRange:_usedCellsRange];
        
        NSUInteger i = [newIndices lastIndex];
        while (i != NSNotFound) {
            MIGAMoreGamesViewCell *cell = [self addCellForIndex:i];
            [_usedCells insertObject:cell atIndex:0];
            
            i = [newIndices indexLessThanIndex:i];
        }
        
        _usedCellsRange.length += [newIndices count];
        _usedCellsRange.location = [newVisibleIndices firstIndex];
        
        NSRange newCellRange = NSMakeRange([newIndices firstIndex],  ([newIndices lastIndex] - [newIndices firstIndex]) + 1);
        newCellRange.location = MIN(0, newCellRange.location - _usedCellsRange.location);
        
        [self layoutCellsInVisibleRange:newCellRange];
        
        [newIndices release];
        
    } else if ((NSLocationInRange(afterTest, _usedCellsRange) == NO) && ([newVisibleIndices containsIndex:afterTest])) {
        
        NSMutableIndexSet *newIndices = [newVisibleIndices mutableCopy];
        [newIndices removeIndexesInRange:_usedCellsRange];
        
        NSUInteger i = [newIndices firstIndex];
        while (i != NSNotFound) {
            MIGAMoreGamesViewCell *cell = [self addCellForIndex:i];
            [_usedCells addObject:cell];
            
            i = [newIndices indexGreaterThanIndex:i];
        }
        
        _usedCellsRange.length += [newIndices count];
        _usedCellsRange.location = [newVisibleIndices firstIndex];
        
        NSRange newCellRange = NSMakeRange([newIndices firstIndex],  ([newIndices lastIndex] - [newIndices firstIndex]) + 1);
        newCellRange.location -= _usedCellsRange.location;
        
        [self layoutCellsInVisibleRange:newCellRange];
        
        [newIndices release];
    }

    [self layoutCellsInVisibleRange:_usedCellsRange];
    if (wereAnimationsEnabled) {
        [UIView setAnimationsEnabled:YES];
    }
}


- (void)layoutCellUsingCellManager:(MIGAMoreGamesViewCell *)cell withInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (!_cellLayoutManager)
        return;

    [_cellLayoutManager performLayoutForCell:cell withInterfaceOrientation:orientation];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_explicitlySettingPage) {
        return;
    }
    
    CGRect cellRect = [self cellRectAtIndex:0];
    CGFloat pageWidth = cellRect.size.width;
    
    NSUInteger newPage = (NSUInteger)(floor((self.contentOffset.x - pageWidth / 2.0) / pageWidth) + 1);

    if (newPage != _currentPage) {
        _currentPage = newPage;
        if (_moreGamesViewDelegate && _delegateRespondsTo.didScrollToPage) {
            [_moreGamesViewDelegate migaMoreGamesView:self didScrollToPage:_currentPage];
        }
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _explicitlySettingPage = NO;
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _explicitlySettingPage = NO;
}


@end
