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
@property (nonatomic, strong) NSCache *thumbnailCache;
@property (readwrite, nonatomic, strong) NSArray *selectedItems;
@property (nonatomic, strong) NSIndexSet *selectionIndexes;

@end

@implementation FPSourceBrowserController

#pragma mark - Accessors

- (NSCache *)thumbnailCache
{
    if (!_thumbnailCache)
    {
        _thumbnailCache = [NSCache new];
        _thumbnailCache.countLimit = 4096;
    }

    return _thumbnailCache;
}

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

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _allowsFileSelection = allowsMultipleSelection;

    self.browserView.allowsMultipleSelection = allowsMultipleSelection;
}

#pragma mark - Public Methods

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.allowsFileSelection = YES;
        self.allowsMultipleSelection = YES;
    }

    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    DLog(@"How many times am I called? %@", self);

    self.browserView.constrainsToOriginalSize = YES;
    self.browserView.cellsStyleMask = IKCellsStyleTitled;

    NSDictionary *titleAttributes = @{
        NSFontAttributeName:[NSFont fontWithName:@"Helvetica" size:12],
        NSForegroundColorAttributeName:[NSColor blackColor]
    };

    NSDictionary *highlightedTitleAttributes = @{
        NSFontAttributeName:[NSFont fontWithName:@"Helvetica" size:12],
        NSForegroundColorAttributeName:[NSColor whiteColor]
    };

    [self.browserView setValue:titleAttributes
                        forKey:IKImageBrowserCellsTitleAttributesKey];

    [self.browserView setValue:highlightedTitleAttributes
                        forKey:IKImageBrowserCellsHighlightedTitleAttributesKey];
}

- (void)dealloc
{
    [self.thumbnailFetchingOperationQueue cancelAllOperations];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IKImageBrowser delegate

- (void)imageBrowserSelectionDidChange:(FPImageBrowserView *)browser
{
    NSMutableArray *items = [NSMutableArray array];

    [browser.selectionIndexes enumerateIndexesUsingBlock: ^(NSUInteger idx,
                                                            BOOL *stop) {
        NSDictionary *item = self.items[idx];

        [items addObject:item];
    }];

    if (items.count == 1 &&
        !self.allowsMultipleSelection &&
        !self.allowsFileSelection)
    {
        NSDictionary *item = items[0];

        if (![item[@"is_dir"] boolValue])
        {
            // Maintain previous selection

            [browser setSelectionIndexes:self.selectionIndexes
                    byExtendingSelection:NO];

            [self.delegate sourceBrowser:self
                didMomentarilySelectItem:item];

            return;
        }
    }

    self.selectedItems = [items copy];

    [self.delegate sourceBrowser:self
              selectionDidChange:self.selectedItems];

    self.selectionIndexes = browser.selectionIndexes;
}

- (void)           imageBrowser:(FPImageBrowserView *)aBrowser
    cellWasDoubleClickedAtIndex:(NSUInteger)index
{
    [self performActionOnSelection];
}

- (void)          imageBrowser:(FPImageBrowserView *)browser
    cellWasRightClickedAtIndex:(NSUInteger)index
                     withEvent:(NSEvent *)event
{
    // No-op
}

- (BOOL)          imageBrowser:(FPImageBrowserView *)aBrowser
    shouldForwardKeyboardEvent:(NSEvent *)event
{
    if (event.modifierFlags & NSCommandKeyMask)
    {
        if (event.keyCode == 0x7E)
        {
            // Cmd+Up pressed

            if (self.delegate &&
                [self.delegate respondsToSelector:@selector(sourceBrowserWantsToGoUpOneDirectory:)])
            {
                [self.delegate sourceBrowserWantsToGoUpOneDirectory:self];
            }

            return NO;
        }
        else if (event.keyCode == 0x7D)
        {
            // Cmd+Down pressed

            if (aBrowser.selectionIndexes.count > 0)
            {
                [self performActionOnSelection];
            }

            return NO;
        }
    }

    return YES;
}

#pragma mark - IKImageBrowser data source

- (NSUInteger)numberOfItemsInImageBrowser:(FPImageBrowserView *)browser
{
    return self.items.count;
}

- (id)imageBrowser:(FPImageBrowserView *)browser
       itemAtIndex:(NSUInteger)index
{
    NSDictionary *item = self.items[index];
    NSString *itemUID = item[@"link_path"];
    FPThumbnail *thumb = [self.thumbnailCache objectForKey:itemUID];
    BOOL isDir = [item[@"is_dir"] boolValue];

    if (!thumb)
    {
        thumb = [FPThumbnail new];

        thumb.UID = itemUID;
        thumb.title = [item[@"display_name"] length] > 0 ? item[@"display_name"] : item[@"filename"];
        thumb.isDimmed = self.allowsFileSelection ? NO : !isDir;

        // Let's display directories using OS X's generic folder icon

        if (isDir)
        {
            thumb.icon = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];

            [self.thumbnailCache setObject:thumb
                                    forKey:itemUID];

            return thumb;
        }

        // Any other icons will be downloaded

        NSURL *iconURL = [NSURL URLWithString:item[@"thumbnail"]];
        NSURLRequest *iconURLRequest = [NSURLRequest requestWithURL:iconURL];

        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:iconURLRequest];

        AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                                 id responseObject) {
            thumb.icon = responseObject;

            [self.thumbnailCache setObject:thumb
                                    forKey:itemUID];

            NSRect cellFrame = [browser itemFrameAtIndex:index];

            [browser setNeedsDisplayInRect:cellFrame];
        };

        AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                                 NSError *error) {
            DLog(@"Thumbnail image %@ load error: %@", itemUID, error);
        };

        [requestOperation setCompletionBlockWithSuccess:successOperationBlock
                                                failure:failureOperationBlock];

        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];

        [requestOperation start];
    }

    return thumb;
}

#pragma mark - Private Methods

- (void)performActionOnSelection
{
    NSArray *items = [self selectedItems];

    // A directory was double-clicked

    if ((items.count == 1) &&
        [items[0][@"is_dir"] boolValue])
    {
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(sourceBrowser:wantsToEnterDirectoryAtPath:)])
        {
            [self.delegate sourceBrowser:self
             wantsToEnterDirectoryAtPath:items[0][@"link_path"]];
        }

        return;
    }

    // For any other cases let's inform our delegate...

    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(sourceBrowser:doubleClickedOnItems:)])
    {
        [self.delegate sourceBrowser:self
                doubleClickedOnItems:items];
    }
}

@end
