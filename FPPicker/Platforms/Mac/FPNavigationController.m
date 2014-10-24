//
//  FPNavigationController.m
//  FPPicker
//
//  Created by Ruben Nine on 22/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPNavigationController.h"
#import "FPRepresentedSource.h"
#import "FPNavigationHistory.h"

typedef enum : NSUInteger
{
    FPNavigateBackDirection = 0,
    FPNavigateForwardDirection = 1
} FPNavigationDirection;

@interface FPNavigationController ()

@property (nonatomic, weak) IBOutlet NSPopUpButton *currentDirectoryPopupButton;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *navigationSegmentedControl;

@property (nonatomic, strong) FPNavigationHistory *navigationHistory;

@end

@implementation FPNavigationController

#pragma mark - Accessors

- (FPNavigationHistory *)navigationHistory
{
    if (!_navigationHistory)
    {
        _navigationHistory = [FPNavigationHistory new];
    }

    return _navigationHistory;
}

- (void)setSourcePath:(FPSourcePath *)sourcePath
{
    _sourcePath = sourcePath;

    if (![self.navigationHistory.currentItem isEqual:sourcePath])
    {
        [self.navigationHistory addItem:sourcePath];
        [self refreshNavigationControls];
    }
}

#pragma mark - Public Methods

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self refreshNavigationControls];
}

- (void)clearNavigation
{
    [self.navigationHistory clear];
    [self refreshNavigationControls];
}

- (void)refreshDirectoriesPopup
{
    if (!self.sourcePath)
    {
        // Without a sourcePath there is nothing we can do.

        return;
    }

    [self.currentDirectoryPopupButton removeAllItems];
    self.currentDirectoryPopupButton.autoenablesItems = NO;

    FPSourcePath *tmpSourcePath = [self.sourcePath copy];

    while (true)
    {
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];

        icon.size = NSMakeSize(16, 16);

        NSMenuItem *menuItem = [NSMenuItem new];

        menuItem.title = tmpSourcePath.path.lastPathComponent.stringByRemovingPercentEncoding;
        menuItem.image = icon;
        menuItem.representedObject = tmpSourcePath;
        menuItem.target = self;
        menuItem.action = @selector(currentDirectoryPopupButtonSelectionChanged:);

        [self.currentDirectoryPopupButton.menu addItem:menuItem];

        if ([tmpSourcePath.parentPath isEqualToString:tmpSourcePath.path])
        {
            break;
        }

        tmpSourcePath.path = tmpSourcePath.parentPath;
    }

    if (self.currentDirectoryPopupButton.itemArray.count > 0)
    {
        [self.currentDirectoryPopupButton selectItemAtIndex:0];
    }
}

#pragma mark - Actions

- (IBAction)navigate:(id)sender
{
    NSSegmentedControl *segmentedControl = sender;
    FPNavigationDirection direction = segmentedControl.selectedSegment;

    switch (direction)
    {
        case FPNavigateBackDirection:
            [self.navigationHistory navigateBack];

            break;

        case FPNavigateForwardDirection:
            [self.navigationHistory navigateForward];

            break;

        default:
            break;
    }

    [self refreshNavigationControls];

    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(navigationController:selectedSourcePath:)])
    {
        [self.delegate navigationController:self
                         selectedSourcePath:[self.navigationHistory currentItem]];
    }
}

- (IBAction)currentDirectoryPopupButtonSelectionChanged:(id)sender
{
    FPSourcePath *sourcePath = [sender representedObject];

    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(navigationController:selectedSourcePath:)])
    {
        [self.delegate navigationController:self
                         selectedSourcePath:sourcePath];
    }
}

#pragma mark - Private Methods

- (void)refreshNavigationControls
{
    [self.navigationSegmentedControl setEnabled:[self.navigationHistory canNavigateBack]
                                     forSegment:FPNavigateBackDirection];

    [self.navigationSegmentedControl setEnabled:[self.navigationHistory canNavigateForward]
                                     forSegment:FPNavigateForwardDirection];
}

@end
