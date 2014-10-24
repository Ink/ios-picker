//
//  FPSourceListController.m
//  FPPicker
//
//  Created by Ruben Nine on 20/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPSourceListController.h"
#import "FPInternalHeaders.h"
#import "FPRepresentedSource.h"
#import "FPSource+SupportedSources.h"
#import "FPTableCellView.h"

const NSString *FPSourceGroupLocal = @"Local";
const NSString *FPSourceGroupRemote = @"Remote";

@interface FPSourceListController ()

@property (nonatomic, strong) NSArray *topLevelItems;
@property (nonatomic, strong) NSMutableDictionary *childrenItems;

@end

@implementation FPSourceListController

#pragma mark - Initializer Methods

- (FPSource *)selectedSource
{
    FPRepresentedSource *representedSource = [self.outlineView itemAtRow:self.outlineView.selectedRow];

    return representedSource.source;
}

- (void)selectSource:(FPSource *)source
{
    NSInteger rowIndex = [self rowIndexForSource:source];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:rowIndex];

    [self.outlineView selectRowIndexes:indexSet
                  byExtendingSelection:NO];
}

#pragma mark - Accessors

- (void)setSourceNames:(NSArray *)sourceNames
{
    _sourceNames = sourceNames;

    self.childrenItems = nil;
}

- (void)setDataTypes:(NSArray *)dataTypes
{
    _dataTypes = dataTypes;

    self.childrenItems = nil;
}

- (NSArray *)topLevelItems
{
    if (!_topLevelItems)
    {
        _topLevelItems = @[
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

        NSArray *activeSources = [FPSource remoteSources];
        NSMutableArray *representedSources = [NSMutableArray array];

        if (self.sourceNames)
        {
            NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"identifier IN %@", self.sourceNames];

            activeSources = [activeSources filteredArrayUsingPredicate:filterPredicate];
        }

        if (self.dataTypes)
        {
            for (FPSource *source in activeSources)
            {
                source.mimetypes = self.dataTypes;
            }
        }

        for (FPSource *source in activeSources)
        {
            FPRepresentedSource *representedSource = [[FPRepresentedSource alloc] initWithSource:source];

            [representedSources addObject:representedSource];
        }

        _childrenItems[FPSourceGroupRemote] = representedSources;
    }

    return _childrenItems;
}

#pragma mark - Public Methods

- (void)cancelAllOperations
{
    [self.childrenItems enumerateKeysAndObjectsUsingBlock: ^(id key,
                                                             id obj,
                                                             BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]])
        {
            for (id entry in obj)
            {
                if ([entry isKindOfClass:[FPRepresentedSource class]])
                {
                    FPRepresentedSource *representedSource = entry;

                    [representedSource cancelAllOperations];
                }
            }
        }
    }];
}

- (void)loadAndExpandSourceList
{
    [self initializeOutlineView];

    // Set initial selection

    FPRepresentedSource *firstRemoteRepresentedSource = self.childrenItems[FPSourceGroupRemote][0];

    [self selectSource:firstRemoteRepresentedSource.source];
}

- (void)refreshOutline
{
    NSIndexSet *selectedRowIndexes = self.outlineView.selectedRowIndexes;

    [self.outlineView reloadData];

    [self.outlineView selectRowIndexes:selectedRowIndexes
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
                                                                owner:nil];

        result.textField.stringValue = [item uppercaseString];

        return result;
    }
    else
    {
        FPTableCellView *result = [outlineView makeViewWithIdentifier:@"DataCell"
                                                                owner:nil];

        FPRepresentedSource *representedSource = item;

        NSString *sourceName = representedSource.source.name;
        NSString *sourceIconName = representedSource.source.icon;

        result.textField.stringValue = sourceName;
        result.imageView.image = [[FPUtils frameworkBundle] imageForResource:sourceIconName];

        [result.button setHidden:!representedSource.isLoggedIn];

        if (representedSource.isLoggedIn)
        {
            result.button.target = self;
            result.button.action = @selector(logoutFromSource:);

            [[result.button cell] setRepresentedObject:representedSource];
        }
        else
        {
            result.button.target = nil;
            result.button.action = nil;

            [[result.button cell] setRepresentedObject:nil];
        }

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

#pragma mark - Actions

- (IBAction)logoutFromSource:(id)sender
{
    FPRepresentedSource *representedSource = [[sender cell] representedObject];
    FPSource *source = representedSource.source;

    NSString *urlString = [NSString stringWithFormat:@"%@/api/client/%@/unauth",
                           fpBASE_URL,
                           source.identifier];

    NSURL *url = [NSURL URLWithString:urlString];

    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:60];

    [sender setEnabled:NO];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

        for (NSString *urlString in source.externalDomains)
        {
            NSArray *siteCookies;
            siteCookies = [cookieStorage cookiesForURL:[NSURL URLWithString:urlString]];

            for (NSHTTPCookie *cookie in siteCookies)
            {
                [cookieStorage deleteCookie:cookie];
            }
        }

        representedSource.isLoggedIn = NO;

        [self refreshOutline];
        [sender setEnabled:YES];

        if (self.delegate)
        {
            [self.delegate sourceListController:self
                            didLogoutFromSource:representedSource];
        }
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        [sender setEnabled:YES];

        [FPUtils presentError:error
              withMessageText:@"Logout failure"];
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    [representedSource.serialOperationQueue cancelAllOperations];
    [representedSource.serialOperationQueue addOperation:operation];
}

#pragma mark - Private Methods

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

- (NSInteger)rowIndexForSource:(FPSource *)source
{
    NSInteger rowIndex = -1;

    for (id topLevelItem in self.topLevelItems)
    {
        for (FPRepresentedSource *item in self.childrenItems[topLevelItem])
        {
            if ([item.source isEqual:source])
            {
                rowIndex = [self.outlineView rowForItem:item];

                break;
            }
        }

        if (rowIndex != -1)
        {
            break;
        }
    }

    return rowIndex;
}

@end
