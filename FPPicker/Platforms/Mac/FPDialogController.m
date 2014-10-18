//
//  FPDialogController.m
//  FPPicker
//
//  Created by Ruben Nine on 17/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPDialogController.h"
#import "FPInternalHeaders.h"
#import "FPSourceListController.h"
#import "FPSourceViewController.h"
#import "FPNavigationController.h"
#import "FPBaseSourceController.h"

@interface FPDialogController () <NSSplitViewDelegate,
                                  NSWindowDelegate,
                                  NSToolbarDelegate,
                                  FPNavigationControllerDelegate,
                                  FPSourceViewControllerDelegate>

@property (nonatomic, weak) IBOutlet NSImageView *fpLogo;
@property (nonatomic, weak) IBOutlet NSToolbar *toolbar;
@property (nonatomic, weak) IBOutlet NSToolbarItem *searchFieldToolbarItem;
@property (nonatomic, weak) IBOutlet NSToolbarItem *currentDirectoryDropdownToolbarItem;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *displayStyleSegmentedControl;
@property (nonatomic, weak) IBOutlet FPSourceViewController *sourceViewController;
@property (nonatomic, weak) IBOutlet FPSourceListController *sourceListController;
@property (nonatomic, weak) IBOutlet FPNavigationController *navigationController;
@property (nonatomic, weak) IBOutlet NSSearchField *searchField;
@property (nonatomic, weak) IBOutlet NSTextField *saveFilenameTextField;

@property (nonatomic, assign) NSModalSession modalSession;

@end

@implementation FPDialogController

#pragma mark - Accessors

- (CGFloat)minSplitPaneWidth
{
    if (!_minSplitPaneWidth)
    {
        _minSplitPaneWidth = 150;
    }

    return _minSplitPaneWidth;
}

- (CGFloat)maxSplitPaneWidth
{
    if (!_maxSplitPaneWidth)
    {
        _maxSplitPaneWidth = 225;
    }

    return _maxSplitPaneWidth;
}

#pragma mark - Public Methods

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.fpLogo.image = [[FPUtils frameworkBundle] imageForResource:@"logo_small"];
}

- (void)open
{
    self.modalSession = [NSApp beginModalSessionForWindow:self.window];

    [NSApp runModalSession:self.modalSession];
}

- (void)close
{
    [self cancelAllOperations];
    [self.window close];
}

- (void)setupSourceListWithSourceNames:(NSArray *)sourceNames
                          andDataTypes:(NSArray *)dataTypes
{
    self.sourceListController.sourceNames = sourceNames;
    self.sourceListController.dataTypes = dataTypes;

    [self.sourceListController loadAndExpandSourceListIfRequired];
}

- (void)setupDialogForSavingWithDefaultFileName:(NSString *)filename
{
    self.saveFilenameTextField.stringValue = filename;
    self.sourceViewController.allowsFileSelection = NO;
    self.sourceViewController.allowsMultipleSelection = NO;
}

- (NSArray *)selectedItems
{
    return self.sourceViewController.selectedItems;
}

- (FPBaseSourceController *)selectedSourceController
{
    return self.sourceViewController.sourceController;
}

- (FPRepresentedSource *)selectedRepresentedSource
{
    return self.selectedSourceController.representedSource;
}

- (void)cancelAllOperations
{
    [self.sourceListController cancelAllOperations];
}

- (NSString *)currentPath
{
    return self.sourceViewController.representedSource.currentPath;
}

- (NSString *)filenameFromSaveTextField
{
    return self.saveFilenameTextField.stringValue;
}

#pragma mark - FPSourceViewControllerDelegate Methods

- (void)sourceViewController:(FPSourceViewController *)sourceViewController
               pathChangedTo:(NSString *)newPath
{
    self.navigationController.currentPath = newPath;
}

- (void)    sourceViewController:(FPSourceViewController *)sourceViewController
    didMomentarilySelectFilename:(NSString *)filename
{
    self.saveFilenameTextField.stringValue = filename;
}

- (void)           sourceViewController:(FPSourceViewController *)sourceViewController
    representedSourceLoginStatusChanged:(FPRepresentedSource *)representedSource
{
    [self.sourceListController refreshOutline];
}

#pragma mark - FPSourceListControllerDelegate Methods

- (void)sourceListController:(FPSourceListController *)sourceListController
             didSelectSource:(FPRepresentedSource *)representedSource
{
    self.sourceViewController.representedSource = representedSource;

    NSUInteger itemIdx = 3;
    NSToolbarItem *item = self.toolbar.visibleItems[itemIdx];

    if (!item)
    {
        return;
    }

    BOOL isImageSearch = [representedSource.source.identifier isEqualToString:FPSourceImagesearch];

    if (isImageSearch)
    {
        if ([item.itemIdentifier isEqualToString:self.currentDirectoryDropdownToolbarItem.itemIdentifier])
        {
            [self.toolbar removeItemAtIndex:itemIdx];

            [self.toolbar insertItemWithItemIdentifier:self.searchFieldToolbarItem.itemIdentifier
                                               atIndex:itemIdx];
        }
    }
    else
    {
        if ([item.itemIdentifier isEqualToString:self.searchFieldToolbarItem.itemIdentifier])
        {
            [self.toolbar removeItemAtIndex:itemIdx];

            [self.toolbar insertItemWithItemIdentifier:self.currentDirectoryDropdownToolbarItem.itemIdentifier
                                               atIndex:itemIdx];
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationController.shouldEnableControls = !isImageSearch;

        self.searchField.stringValue = @"";

        [self.searchField setHidden:!isImageSearch];
    });
}

- (void)sourceListController:(FPSourceListController *)sourceListController
         didLogoutFromSource:(FPRepresentedSource *)representedSource
{
    if ([self.sourceViewController.sourceController.representedSource isEqualTo:representedSource])
    {
        [self.sourceViewController.sourceController fpLoadContentAtPath:YES];
    }
}

#pragma mark - FPNavigationControllerDelegate Methods

- (void)currentDirectoryPopupButtonSelectionChanged:(NSString *)newPath
{
    [self.sourceViewController loadPath:newPath];
}

#pragma mark - NSToolbarDelegate Methods

- (NSToolbarItem *)   toolbar:(NSToolbar *)toolbar
        itemForItemIdentifier:(NSString *)itemIdentifier
    willBeInsertedIntoToolbar:(BOOL)flag
{
    if ([itemIdentifier isEqualToString:self.searchFieldToolbarItem.itemIdentifier])
    {
        return self.searchFieldToolbarItem;
    }
    else if ([itemIdentifier isEqualToString:self.currentDirectoryDropdownToolbarItem.itemIdentifier])
    {
        return self.currentDirectoryDropdownToolbarItem;
    }
    else
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"%@ is not a supported item identifier", itemIdentifier];
    }

    return nil;
}

#pragma mark - NSSplitViewDelegate Methods

- (BOOL)           splitView:(NSSplitView *)splitView
    shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
    return YES;
}

- (BOOL)     splitView:(NSSplitView *)splitView
    canCollapseSubview:(NSView *)subview
{
    return NO;
}

- (CGFloat)      splitView:(NSSplitView *)splitView
    constrainMinCoordinate:(CGFloat)proposedMinimumPosition
               ofSubviewAt:(NSInteger)dividerIndex
{
    if (proposedMinimumPosition < self.minSplitPaneWidth)
    {
        proposedMinimumPosition = self.minSplitPaneWidth;
    }

    return proposedMinimumPosition;
}

- (CGFloat)      splitView:(NSSplitView *)splitView
    constrainMaxCoordinate:(CGFloat)proposedMinimumPosition
               ofSubviewAt:(NSInteger)dividerIndex
{
    if (proposedMinimumPosition > self.maxSplitPaneWidth)
    {
        proposedMinimumPosition = self.maxSplitPaneWidth;
    }

    return proposedMinimumPosition;
}

#pragma mark - NSWindowDelegate Methods

- (void)windowWillClose:(NSNotification *)notification
{
    if (self.modalSession)
    {
        [NSApp endModalSession:self.modalSession];
    }
}

#pragma mark - NSWindowControllerDelegate Methods

- (void)windowDidLoad
{
    [super windowDidLoad];

    self.window.styleMask &= ~NSTexturedBackgroundWindowMask;

    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(dialogControllerDidLoadWindow:)])
    {
        [self.delegate dialogControllerDidLoadWindow:self];
    }
}

#pragma mark - Actions

- (IBAction)performAction:(id)sender
{
    if (self.delegate)
    {
        [self.delegate dialogControllerPressedActionButton:self];
    }
    else
    {
        NSForceLog(@"Perform action called, but no delegate found to handle it.");
    }
}

- (IBAction)cancelAction:(id)sender
{
    if (self.delegate)
    {
        [self.delegate dialogControllerPressedCancelButton:self];
    }
    else
    {
        NSForceLog(@"Cancel action called, but no delegate found to handle it.");
    }
}

@end
