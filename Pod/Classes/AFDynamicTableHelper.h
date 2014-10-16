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

@import UIKit;

@protocol AFDynamicTableHelperDelegate;

/*
 Helps to compute the heights of rows for dynamic table cells that use Auto Layout for iOS 7.x
 If you only support 8.0+, you don't need this.
 
 For iOS >= 8.0, uses the native implementation.
 For iOS 7.x uses the method described in [1] with some tweaks.
 
 [1] http://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-variable-row-heights
 */
@interface AFDynamicTableHelper : NSObject

@property (nonatomic, weak) id<AFDynamicTableHelperDelegate> delegate;

/// If all the identifiers are the same, set this.
/// Otherwise use the delegate.
@property (nonatomic, copy) NSString *reusableCellIdentifier;

/// Call these methods in your table view delegate / data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

// Call these when your content changes
- (void)invalidateCellHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateAllCellHeights;

@end

@protocol AFDynamicTableHelperDelegate <NSObject>
@optional

- (NSString *)dynamicTableHelper:(AFDynamicTableHelper *)tableHelper
    reusableCellIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath
                       tableView:(UITableView *)tableView;

- (void)dynamicTableHelper:(AFDynamicTableHelper *)tableHelper
               prepareCell:(UITableViewCell *)cell
               atIndexPath:(NSIndexPath *)indexPath
                 tableView:(UITableView *)tableView
                 offscreen:(BOOL)offscreen;

@end
