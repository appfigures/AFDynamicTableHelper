// Copyright (c) 2014 appFigures Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFDynamicTableHelper.h"

// Tried to use the raw index path as
// the dictionary key, but it didn't seem to work correctly.
// Also read that it's slow: http://corecocoa.wordpress.com/2014/01/14/any-thing-can-be-a-dictionary-key-yes-but-with-a-price/
#define _indexPathString(_ip_) [NSString stringWithFormat:@"%li_%li", (long)_ip_.section, (long)_ip_.row]

static BOOL isNativeSupportAvailable = NO;

@interface AFDynamicTableHelper()
{
    BOOL _delegateImpsReusableCellId;
    BOOL _delegateImpsPrepareCell;
}

// These will never invalidate. If your prototype cells change
// (very unlikely) just make a new instance of this class.
@property (nonatomic, strong) NSMutableDictionary *offscreenCells;
@property (nonatomic, strong) NSMutableDictionary *offscreenCellsConstraints;
// This little cache gives a great speed boost.
@property (nonatomic, strong) NSMutableDictionary *cellHeights;

@end

@implementation AFDynamicTableHelper

+ (void)initialize {
    // Couldn't find a nicer way to detect availability.
    isNativeSupportAvailable = ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending);
}

- (id)init {
    self = [super init];
    if (self) {
        if (!isNativeSupportAvailable) {
            _offscreenCells = [[NSMutableDictionary alloc] init];
            _offscreenCellsConstraints = [[NSMutableDictionary alloc] init];
            _cellHeights = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)invalidateCellHeightAtIndexPath:(NSIndexPath *)indexPath {
    if (isNativeSupportAvailable) {
        return;
    }
    
    if (indexPath) {
        NSString *indexPathString = _indexPathString(indexPath);
        [_cellHeights removeObjectForKey:indexPathString];
    }
}

- (void)invalidateAllCellHeights {
    if (isNativeSupportAvailable) {
        return;
    }
    
    [_cellHeights removeAllObjects];
}

#pragma mark - Properties

- (void)setDelegate:(id<AFDynamicTableHelperDelegate>)delegate {
    if (delegate == _delegate) return;
    
    _delegate = delegate;
    
    // Let's cache this delegate's capabilities to
    // avoid calling respondsToSelector: t0o much.
    _delegateImpsReusableCellId = [delegate respondsToSelector:@selector(dynamicTableHelper:reusableCellIdentifierForRowAtIndexPath:tableView:)];
    _delegateImpsPrepareCell = [delegate respondsToSelector:@selector(dynamicTableHelper:prepareCell:atIndexPath:tableView:offscreen:)];
}

#pragma mark - Private

- (NSString *)_reusableCellIdWithTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    if (_delegateImpsReusableCellId) {
        return [_delegate dynamicTableHelper:self reusableCellIdentifierForRowAtIndexPath:indexPath tableView:tableView];
    }
    
    return _reusableCellIdentifier;
}

#pragma mark - Main

// Since these methods are called a lot, they are tuned for performance

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isNativeSupportAvailable) {
        return UITableViewAutomaticDimension;
    }
    
    NSMutableDictionary *cellHeights = _cellHeights;
    
    NSString *indexPathString = _indexPathString(indexPath);
    NSNumber *cachedHeight = [cellHeights objectForKey:indexPathString];
    
    if (cachedHeight) {
        return (CGFloat)[cachedHeight floatValue];
    }
    
    NSString *reusableCellId = [self _reusableCellIdWithTable:tableView indexPath:indexPath];
    
    NSAssert(reusableCellId, @"No valid reusableCellIndentifier provided for cell at index path %@", indexPath);
    
    NSMutableDictionary *offscreenCells = _offscreenCells;
    
    UITableViewCell *cell = [offscreenCells objectForKey:reusableCellId];
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:reusableCellId];
        
        NSAssert(cell, @"Couldn't dequeue cell from table with reusableIdentifier '%@'", reusableCellId);
        
        [offscreenCells setObject:cell forKey:reusableCellId];
    }
    
    // Get the cell's constraint
    NSMutableDictionary *offscreenCellsConstraints = _offscreenCellsConstraints;
    NSLayoutConstraint *widthConstraint = [offscreenCellsConstraints objectForKey:reusableCellId];
    if (!widthConstraint) {
        widthConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1.0
                                                        constant:0.0];
        
        [_offscreenCellsConstraints setObject:widthConstraint forKey:reusableCellId];
    }
    
    if (_delegateImpsPrepareCell) {
        [_delegate dynamicTableHelper:self prepareCell:cell atIndexPath:indexPath tableView:tableView offscreen:YES];
    }
    
    // Set the width of the cell to match the width of the table view. This is important so that we'll get the
    // correct cell height for different table view widths if the cell's height depends on its width (due to
    // multi-line UILabels word wrapping, etc). We don't need to do this above in -[tableView:cellForRowAtIndexPath]
    // because it happens automatically when the cell is used in the table view.
    // Also note, the final width of the cell may not be the width of the table view in some cases, for example when a
    // section index is displayed along the right side of the table view. You must account for the reduced cell width.
    widthConstraint.constant = tableView.bounds.size.width;
    [cell.contentView addConstraint:widthConstraint];
    
    // Make sure the constraints have been set up for this cell, since it may have just been created from scratch.
    // Use the following lines, assuming you are setting up constraints from within the cell's updateConstraints method:
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints.
    // (Note that you must set the preferredMaxLayoutWidth on multi-line UILabels inside the -[layoutSubviews] method
    // of the UITableViewCell subclass, or do it manually at this point before the below 2 lines!)
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell's contentView
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    [cell.contentView removeConstraint:widthConstraint];
    
    CGFloat height = size.height;
    
    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    if (tableView.separatorStyle != UITableViewCellSeparatorStyleNone) {
        height += 1.0f;
    }
    
    [cellHeights setObject:@(height) forKey:indexPathString];
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reusableCellId = [self _reusableCellIdWithTable:tableView indexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellId forIndexPath:indexPath];
    
    if (_delegateImpsPrepareCell) {
        [_delegate dynamicTableHelper:self prepareCell:cell atIndexPath:indexPath tableView:tableView offscreen:NO];
    }
    
    // Make sure the constraints have been set up for this cell, since it may have just been created from scratch.
    // Use the following lines, assuming you are setting up constraints from within the cell's updateConstraints method:
    
    // NOTE: This seems to cause warnings on iOS 7.0
//    [cell setNeedsUpdateConstraints];
//    [cell updateConstraintsIfNeeded];
    
    return cell;
}

@end
