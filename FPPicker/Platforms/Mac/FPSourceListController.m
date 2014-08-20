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

@end

@implementation FPSourceListController

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.topLevelItems = @[FPSourceGroupLocal, FPSourceGroupRemote];

    self.childrenItems = [NSMutableDictionary new];
    self.childrenItems[FPSourceGroupLocal] = [FPSource localDesktopSources];
    self.childrenItems[FPSourceGroupRemote] = [FPSource remoteSources];

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

    // Set initial selection

    FPSource *firstRemoteSource = self.childrenItems[FPSourceGroupRemote][0];
    NSInteger row = [self.outlineView rowForItem:firstRemoteSource];
    NSIndexSet *rowIndex = [NSIndexSet indexSetWithIndex:row];

    [self.outlineView selectRowIndexes:rowIndex
                  byExtendingSelection:NO];
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
                                                                owner:self];

        result.textField.stringValue = [item uppercaseString];

        return result;
    }
    else
    {
        NSTableCellView *result = [outlineView makeViewWithIdentifier:@"DataCell"
                                                                owner:self];

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

@end
