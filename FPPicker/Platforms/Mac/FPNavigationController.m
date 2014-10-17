//
//  FPNavigationController.m
//  FPPicker
//
//  Created by Ruben Nine on 22/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPNavigationController.h"

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

- (void)setCurrentPath:(NSString *)currentPath
{
    _currentPath = currentPath;

    if (currentPath)
    {
        [self populateCurrentDirectoryPopupButton];
    }
}

#pragma mark - Private Methods

- (void)populateCurrentDirectoryPopupButton
{
    [self.currentDirectoryPopupButton removeAllItems];
    self.currentDirectoryPopupButton.autoenablesItems = NO;

    NSString *tmpPath = self.currentPath;

    while (tmpPath.pathComponents.count > 2)
    {
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];

        icon.size = NSMakeSize(16, 16);

        NSMenuItem *menuItem = [NSMenuItem new];

        menuItem.title = tmpPath.lastPathComponent.stringByRemovingPercentEncoding;
        menuItem.image = icon;
        menuItem.representedObject = tmpPath;
        menuItem.target = self;
        menuItem.action = @selector(currentDirectoryPopupButtonSelectionChanged:);

        [self.currentDirectoryPopupButton.menu addItem:menuItem];

        tmpPath = [tmpPath.stringByDeletingLastPathComponent stringByAppendingString:@"/"];
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
