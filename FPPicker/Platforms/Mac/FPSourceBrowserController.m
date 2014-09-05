//
//  FPSourceBrowserController.m
//  FPPicker
//
//  Created by Ruben Nine on 01/09/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPSourceBrowserController.h"
#import "FPInternalHeaders.h"
#import "FPThumbnail.h"

@interface FPSourceBrowserController ()

@property (nonatomic, strong) NSOperationQueue *thumbnailFetchingOperationQueue;

@end

@implementation FPSourceBrowserController

#pragma mark - Accessors

- (NSOperationQueue *)thumbnailFetchingOperationQueue
{
    if (!_thumbnailFetchingOperationQueue)
    {
        _thumbnailFetchingOperationQueue = [NSOperationQueue new];
        _thumbnailFetchingOperationQueue.maxConcurrentOperationCount = 5;
    }

    return _thumbnailFetchingOperationQueue;
}

- (void)setItems:(NSArray *)items
{
    [self.thumbnailFetchingOperationQueue cancelAllOperations];

    _items = items;
}

#pragma mark - Public Methods

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.thumbnailListView.constrainsToOriginalSize = YES;
    self.thumbnailListView.cellsStyleMask = IKCellsStyleTitled;

    NSDictionary *titleAttributes = @{
        NSFontAttributeName:[NSFont fontWithName:@"Helvetica" size:12],
        NSForegroundColorAttributeName:[NSColor blackColor]
    };

    NSDictionary *highlightedTitleAttributes = @{
        NSFontAttributeName:[NSFont fontWithName:@"Helvetica" size:12],
        NSForegroundColorAttributeName:[NSColor whiteColor]
    };

    [self.thumbnailListView setValue:titleAttributes
                              forKey:IKImageBrowserCellsTitleAttributesKey];

    [self.thumbnailListView setValue:highlightedTitleAttributes
                              forKey:IKImageBrowserCellsHighlightedTitleAttributesKey];
}

- (void)dealloc
{
    [self.thumbnailFetchingOperationQueue cancelAllOperations];
}

#pragma mark - IKImageBrowser delegate

- (void)imageBrowserSelectionDidChange:(IKImageBrowserView *)browser
{
    DLog(@"Selection did change %@", browser.selectionIndexes);

    NSNumber *selectionCount = @(browser.selectionIndexes.count);

    [[NSNotificationCenter defaultCenter] postNotificationName:FPBrowserSelectionDidChangeNotification
                                                        object:selectionCount];
}

- (void)           imageBrowser:(IKImageBrowserView *)aBrowser
    cellWasDoubleClickedAtIndex:(NSUInteger)index
{
    NSDictionary *item = self.items[index];

    if ([item[@"is_dir"] boolValue])
    {
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(sourceBrowserWantsToChangeCurrentDirectory:)])
        {
            [self.delegate sourceBrowserWantsToChangeCurrentDirectory:item[@"link_path"]];
        }
    }
}

- (void)          imageBrowser:(IKImageBrowserView *)browser
    cellWasRightClickedAtIndex:(NSUInteger)index
                     withEvent:(NSEvent *)event
{
    // No-op
}

#pragma mark - IKImageBrowser data source

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)browser
{
    return self.items.count;
}

- (id)imageBrowser:(IKImageBrowserView *)browser
       itemAtIndex:(NSUInteger)index
{
    NSDictionary *item = self.items[index];
    FPThumbnail *thumb = [FPThumbnail new];

    thumb.UID = item[@"link_path"];
    thumb.title = [item[@"display_name"] length] > 0 ? item[@"display_name"] : item[@"filename"];

    NSBlockOperation *thumbnailFetchingOperation = [NSBlockOperation blockOperationWithBlock: ^{
        NSURL *iconURL = [NSURL URLWithString:item[@"thumbnail"]];

        thumb.icon = [[NSImage alloc] initWithContentsOfURL:iconURL];

        NSRect cellFrame = [browser itemFrameAtIndex:index];

        [browser setNeedsDisplayInRect:cellFrame];
    }];

    [self.thumbnailFetchingOperationQueue addOperation:thumbnailFetchingOperation];

    return thumb;
}

@end
