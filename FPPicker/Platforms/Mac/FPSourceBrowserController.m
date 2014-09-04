//
//  FPSourceBrowserController.m
//  FPPicker
//
//  Created by Ruben Nine on 01/09/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPSourceBrowserController.h"
#import "FPUtils.h"
#import "FPThumbnail.h"

@implementation FPSourceBrowserController

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

#pragma mark - IKImageBrowser delegate

- (void)imageBrowserSelectionDidChange:(IKImageBrowserView *)browser
{
    DLog(@"Selection did change %@", browser.selectionIndexes);
}

- (void)          imageBrowser:(IKImageBrowserView *)browser
    cellWasRightClickedAtIndex:(NSUInteger)index
                     withEvent:(NSEvent *)event
{
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

    dispatch_async(dispatch_get_main_queue(), ^{
        // Load thumbnail asynchronously
        // and force redraw of affected thumbnail's rect in browser

        NSURL *iconURL = [NSURL URLWithString:item[@"thumbnail"]];

        thumb.icon = [[NSImage alloc] initWithContentsOfURL:iconURL];

        NSRect cellFrame = [browser itemFrameAtIndex:index];

        [browser setNeedsDisplayInRect:cellFrame];
    });

    return thumb;
}

@end
