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

#import "SimpleListController.h"
#import <AFDynamicTableHelper/AFDynamicTableHelper.h>
#import "MyDynamicTableViewCell.h"

@interface SimpleListController ()<AFDynamicTableHelperDelegate>

@property (nonatomic, strong) AFDynamicTableHelper *tableHelper;
@property (nonatomic, strong) NSArray *data;

@end

@implementation SimpleListController

- (void)awakeFromNib {
    self.tableHelper.reusableCellIdentifier = @"myDynamicCell";
}

// Lazy properties
- (AFDynamicTableHelper *)tableHelper {
    if (!_tableHelper) {
        _tableHelper = [[AFDynamicTableHelper alloc] init];
        _tableHelper.delegate = self;
    }
    return _tableHelper;
}

- (NSArray *)data {
    if (!_data) {
        int num = 30;
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:num];
        
        for (int i = 0; i < num; ++i) {
            int numLetters = arc4random() % 100 + 20;
            
            NSMutableString *bodyString = [[NSMutableString alloc] initWithCapacity:numLetters];
            
            for (int j = 0; j < numLetters; ++j) {
                [bodyString appendString:@"A"];
            }
            
            [array addObject:@{
                              @"title": [NSString stringWithFormat:@"This one has %i letters", numLetters],
                              @"body": [bodyString copy]
                              }];
        }
        
        _data = [array copy];
    }
    return _data;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_tableHelper invalidateAllCellHeights];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableHelper tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableHelper tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - AFDynamicTableHelper delegate

- (void)dynamicTableHelper:(AFDynamicTableHelper *)tableHelper prepareCell:(UITableViewCell *)_cell atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView offscreen:(BOOL)offscreen {
    MyDynamicTableViewCell *cell = (MyDynamicTableViewCell *)_cell;
    NSDictionary *datum = self.data[indexPath.row];
    
    cell.headerLabel.text = datum[@"title"];
    cell.bodyLabel.text = datum[@"body"];
}

@end
