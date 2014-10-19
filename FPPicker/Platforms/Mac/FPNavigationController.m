//
//  FPNavigationController.m
//  FPPicker
//
//  Created by Ruben Nine on 22/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPNavigationController.h"
#import "FPRepresentedSource.h"

@interface FPNavigationController ()

@property (nonatomic, weak) IBOutlet NSPopUpButton *currentDirectoryPopupButton;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *navigationSegmentedControl;

@end

@implementation FPNavigationController

#pragma mark - Accessors

- (void)setShouldEnableControls:(BOOL)shouldEnableControls
{
    _shouldEnableControls = shouldEnableControls;

    [self.currentDirectoryPopupButton setEnabled:shouldEnableControls];
    [self.navigationSegmentedControl setEnabled:shouldEnableControls];
}

#pragma mark - Private Methods

- (void)refreshDirectoriesPopup
{
    [self.currentDirectoryPopupButton removeAllItems];
    self.currentDirectoryPopupButton.autoenablesItems = NO;

    FPSourcePath *sourcePath = [self.representedSource.sourcePath copy];

    if (!sourcePath)
    {
        return;
    }

    while (true)
    {
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];

        icon.size = NSMakeSize(16, 16);

        NSMenuItem *menuItem = [NSMenuItem new];

        menuItem.title = sourcePath.path.lastPathComponent.stringByRemovingPercentEncoding;
        menuItem.image = icon;
        menuItem.representedObject = sourcePath.path;
        menuItem.target = self;
        menuItem.action = @selector(currentDirectoryPopupButtonSelectionChanged:);

        [self.currentDirectoryPopupButton.menu addItem:menuItem];

        if ([sourcePath.parentPath isEqualToString:sourcePath.path])
        {
            break;
        }

        sourcePath.path = sourcePath.parentPath;
    }

    if (self.currentDirectoryPopupButton.itemArray.count > 0)
    {
        [self.currentDirectoryPopupButton selectItemAtIndex:0];
    }
}

- (IBAction)currentDirectoryPopupButtonSelectionChanged:(id)sender
{
    NSString *newPath = [sender representedObject];

    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(currentDirectoryPopupButtonSelectionChanged:)])
    {
        [self.delegate currentDirectoryPopupButtonSelectionChanged:newPath];
    }
}

@end
