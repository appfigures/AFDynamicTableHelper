# AFDynamicTableHelper

Create dynamic height table cells with auto layout in iOS >= 7.0.

Are you building an app that targets iOS >= 7.0 and need to create table views with dynamic cell heights? This little helper takes care of all the quirks you need to do it right. On iOS 8.0 it takes advantage of the new auto-sizing capabilities automatically.

If you're only targeting 8.0+ you don't need this class. Just use the built in `UITableViewAutomaticDimension`.

Still here? Read on:

If you're unfamilar with the quirks involved in implementing dynamic height table views for iOS 7 I highly recommend reading [this stackoverflow question](http://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-variable-row-heights). A lot of the code for this class is based on that question.

## Usage

This utility is a simple `NSObject` that provides you with concrete implementations for the deceivingly-non-trivial-to-implement:

    tableView:heightForRowAtIndexPath:

and

    tableView:cellForRowAtIndexPath:

A simple use-case looks something like this:

    @implementation MyTableViewController
    ...
    - (void)awakeFromNib {
        self.tableHelper = [[AFDynamicTableHelper alloc] init];
        self.tableHelper.delegate = self;
        self.tableHelper.reusableCellIdentifier = @"myCell";
    }
    
    /* ... the usual tableView delegate methods... */
    
    // Just forward these methods over to the dynamic table helper and get on with your day.
    
    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        return [self.tableHelper tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return [self.tableHelper tableView:tableView heightForRowAtIndexPath:indexPath];
    }

Check out a complete example in the [demo project].

### Customizing your cells

In order to do its magic this class needs to manage the way table cells are created and populated. The only thing it asks is that instead of setting up your cell in the usual `tableView:cellForRowAtIndexPath:` you implement the following delegate method:

    - (void)dynamicTableHelper:(AFDynamicTableHelper *)tableHelper
                   prepareCell:(UITableViewCell *)cell
                   atIndexPath:(NSIndexPath *)indexPath
                     tableView:(UITableView *)tableView
                     offscreen:(BOOL)offscreen
    {
        // `cell` is created for you based on
        // tableHelper.reusableCellIdentifier. You just
        // need to populate it.
    
        // `offscreen` specifies if this cell will be used solely for height
        // measurements purposes so you can avoid doing
        // any expensive setup steps that don't affect the
        // cell's height.
    
        // the `offscreen` argument is only here for optimization purposes
        // and can be safely ignored if you don't want to deal
        // with it.
    }

### What happens on iOS >= 8.0?

When this class detects iOS >= 8.0 it does about 95% less work and just returns `UITableViewAutomaticDimension` when asked for a cell's height. The key thing is that your code doesn't need to change depending on the version of iOS. That logic is taken care of behind the scenes.

### What if I use multiple cell prototypes?

Just implement the delegate method `dynamicTableHelper:reusableCellIdentifierForRowAtIndexPath:tableView:`

## Installation

AFDynamicTableHelper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "AFDynamicTableHelper"

## Author

Oz Michaeli from appFigures

## License

AFDynamicTableHelper is available under the MIT license. See the LICENSE file for more info.

