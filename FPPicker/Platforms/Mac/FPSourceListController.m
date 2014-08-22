//
//  FPSourceListController.m
//  FPPicker
//
//  Created by Ruben Nine on 20/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPSourceListController.h"
#import "FPInternalHeaders.h"
#import "FPSource+SupportedSources.h"

const NSString *FPSourceGroupLocal = @"Local";
const NSString *FPSourceGroupRemote = @"Remote";

@interface FPSourceListController ()

@property (nonatomic, strong) NSArray *topLevelItems;
@property (nonatomic, strong) NSMutableDictionary *childrenItems;
@property (nonatomic, assign) BOOL isSourceListLoaded;

@end

@implementation FPSourceListController

#pragma mark - Initializer Methods

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.isSourceListLoaded = NO;
    }

    return self;
}

#pragma mark - Accessors

- (NSArray *)topLevelItems
{
    if (!_topLevelItems)
    {
        _topLevelItems = @[
            FPSourceGroupLocal,
            FPSourceGroupRemote
                         ];
    }

    return _topLevelItems;
}

- (NSMutableDictionary *)childrenItems
{
    if (!_childrenItems)
    {
        _childrenItems = [NSMutableDictionary new];

        _childrenItems[FPSourceGroupLocal] = [FPSource localDesktopSources];
        _childrenItems[FPSourceGroupRemote] = [FPSource remoteSources];
    }

    return _childrenItems;
}

#pragma mark - Public Methods

- (void)loadAndExpandSourceListIfRequired
{
    // NOTE: We could inherit from NSViewController and use -viewDidAppear
    // rather than calling this method manually, but, unfortunately,
    // all the -view(Did|Will)* methods were introduced in 10.10 APIs.

    @synchronized(self)
    {
        // We only load them once.

        if (self.isSourceListLoaded)
        {
            return;
        }

        [self initializeOutlineView];

        // Set initial selection

        FPSource *firstRemoteSource = self.childrenItems[FPSourceGroupRemote][0];
        NSInteger row = [self.outlineView rowForItem:firstRemoteSource];
        NSIndexSet *rowIndex = [NSIndexSet indexSetWithIndex:row];

        [self.outlineView selectRowIndexes:rowIndex
                      byExtendingSelection:NO];

        self.isSourceListLoaded = YES;
    }
}

#pragma mark - NSOutlineViewDelegate Methods

- (NSView *)outlineView:(NSOutlineView *)outlineView
     viewForTableColumn:(NSTableColumn *)tableColumn
                   item:(id)item
{
    // For the groups, we just return a regular text view.

    if ([self.topLevelItems containsObject:item])
    {
        NSTableCellView *result = [outlineView makeViewWithIdentifier:@"HeaderCell"
                                                                owner:nil];

        result.textField.stringValue = [item uppercaseString];

        return result;
    }
    else
    {
        NSTableCellView *result = [outlineView makeViewWithIdentifier:@"DataCell"
                                                                owner:nil];

        FPSource *source = item;

        result.textField.stringValue = source.name;
        result.imageView.image = [[FPUtils frameworkBundle] imageForResource:source.icon];

        return result;
    }
}

- (BOOL)             outlineView:(NSOutlineView *)outlineView
    shouldShowOutlineCellForItem:(id)item
{
    return NO;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView
    shouldSelectItem:(id)item
{
    if ([self.topLevelItems containsObject:item])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    if (self.outlineView.selectedRow != -1)
    {
        id item = [self.outlineView itemAtRow:self.outlineView.selectedRow];

        if ([self.outlineView parentForItem:item])
        {
            if (self.delegate)
            {
                [self.delegate sourceListController:self
                                    didSelectSource:item];
            }
        }
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
        isGroupItem:(id)item
{
    return [self.topLevelItems containsObject:item];
}

#pragma mark - NSOutlineViewDataSource Methods

- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(id)item
{
    return [self childrenForItem:item][index];
}

- (BOOL) outlineView:(NSOutlineView *)outlineView
    isItemExpandable:(id)item
{
    if (![outlineView parentForItem:item])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSInteger)  outlineView:(NSOutlineView *)outlineView
    numberOfChildrenOfItem:(id)item
{
    NSArray *childrenForItem = [self childrenForItem:item];

    return childrenForItem.count;
}

#pragma mark - Private Methods

- (NSArray *)childrenForItem:(id)item
{
    NSArray *children;

    if (!item)
    {
        children = self.topLevelItems;
    }
    else
    {
        children = self.childrenItems[item];
    }

    return children;
}

- (void)initializeOutlineView
{
    [self.outlineView sizeLastColumnToFit];
    [self.outlineView reloadData];
    [self.outlineView setFloatsGroupRows:NO];
    [self.outlineView setRowSizeStyle:NSTableViewRowSizeStyleDefault];

    // Expand all the root items; disable the expansion animation that normally happens

    [NSAnimationContext beginGrouping];
    {
        [[NSAnimationContext currentContext] setDuration:0];

        [self.outlineView expandItem:nil
                      expandChildren:YES];
    }
    [NSAnimationContext endGrouping];
}

@end
