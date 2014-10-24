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

- (instancetype)initWithWindowNibName:(NSString *)windowNibName
                                owner:(id)owner
{
    NSBundle *bundle;

    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"FPPickerMac"
                                               withExtension:@"bundle"];

    if (bundleURL)
    {
        bundle = [NSBundle bundleWithURL:bundleURL];
    }
    else
    {
        bundle = [NSBundle bundleForClass:self.class];
    }

    NSURL *nibURL = [bundle URLForResource:windowNibName
                             withExtension:@"nib"];

    self = [self initWithWindowNibPath:nibURL.path
                                 owner:owner];

    return self;
}

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
    [self.navigationController clearNavigation];

    self.sourceListController.sourceNames = sourceNames;
    self.sourceListController.dataTypes = dataTypes;

    [self.sourceListController loadAndExpandSourceList];
}

- (void)setupDialogForOpening
{
    self.sourceViewController.allowsFileSelection = YES;
    self.sourceViewController.allowsMultipleSelection = YES;
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

- (FPRepresentedSource *)selectedRepresentedSource
{
    return self.sourceViewController.representedSource;
}

- (void)cancelAllOperations
{
    [self.sourceListController cancelAllOperations];
}

- (NSString *)filenameFromSaveTextField
{
    return self.saveFilenameTextField.stringValue;
}

#pragma mark - FPSourceViewControllerDelegate Methods

- (void)sourceViewController:(FPSourceViewController *)sourceViewController
        doubleClickedOnItems:(NSArray *)items
{
    [self.delegate dialogControllerPressedActionButton:self];
}

- (void)sourceViewController:(FPSourceViewController *)sourceViewController
           sourcePathChanged:(FPSourcePath *)sourcePath
{
    self.navigationController.sourcePath = sourcePath;

    [self.navigationController refreshDirectoriesPopup];
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

    NSToolbarItem *toolbarItemToRemove;
    NSToolbarItem *toolbarItemToInsert;

    if (isImageSearch)
    {
        toolbarItemToRemove = self.currentDirectoryDropdownToolbarItem;
        toolbarItemToInsert = self.searchFieldToolbarItem;
    }
    else
    {
        toolbarItemToRemove = self.searchFieldToolbarItem;
        toolbarItemToInsert = self.currentDirectoryDropdownToolbarItem;
    }

    if ([item.itemIdentifier isEqualToString:toolbarItemToRemove.itemIdentifier])
    {
        [self.toolbar removeItemAtIndex:itemIdx];

        [self.toolbar insertItemWithItemIdentifier:toolbarItemToInsert.itemIdentifier
                                           atIndex:itemIdx];
    }

    self.searchField.stringValue = @"";

    [self.searchField setHidden:!isImageSearch];
}

- (void)sourceListController:(FPSourceListController *)sourceListController
         didLogoutFromSource:(FPRepresentedSource *)representedSource
{
    if ([self.sourceViewController.representedSource isEqualTo:representedSource])
    {
        [self.sourceViewController.sourceController loadContentsAtPathInvalidatingCache:YES];
    }
}

#pragma mark - FPNavigationControllerDelegate Methods

- (void)navigationController:(FPNavigationController *)navigationController
          selectedSourcePath:(FPSourcePath *)sourcePath
{
    if (![sourcePath.source isEqual:[self.sourceListController selectedSource]])
    {
        // Select new source on source list

        [self.sourceListController selectSource:sourcePath.source];
    }
    else
    {
        // Load path on existing source

        [self.sourceViewController loadPath:sourcePath.path];
    }
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
