//
//  FPSourceViewController.m
//  FPPicker
//
//  Created by Ruben on 9/25/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPSourceViewController.h"
#import "FPSourceListController.h"
#import "FPSourceResultsController.h"
#import "FPRemoteSourceController.h"
#import "FPImageSearchSourceController.h"
#import "FPNavigationController.h"
#import "FPAuthController.h"
#import "FPInternalHeaders.h"

typedef enum : NSUInteger
{
    FPAuthenticationTabView = 0,
    FPBrowserViewTabView = 1,
    FPTableViewTabView = 2
} FPSourceTabView;


@interface FPSourceViewController () <FPSourceResultsControllerDelegate,
                                      FPRemoteSourceControllerDelegate>

@property (nonatomic, weak) IBOutlet NSSegmentedControl *displayStyleSegmentedControl;

@property (readwrite, nonatomic) FPBaseSourceController *sourceController;

@end


@implementation FPSourceViewController

#pragma mark - Accessors

- (void)setAllowsFileSelection:(BOOL)allowsFileSelection
{
    _allowsFileSelection = allowsFileSelection;

    self.sourceResultsController.allowsFileSelection = allowsFileSelection;

    [self.currentSelectionTextField setHidden:!allowsFileSelection];
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _allowsMultipleSelection = allowsMultipleSelection;

    self.sourceResultsController.allowsMultipleSelection = allowsMultipleSelection;
}

- (void)setRepresentedSource:(FPRepresentedSource *)representedSource
{
    if (representedSource != _representedSource)
    {
        _representedSource = representedSource;

        [self cancelAllOperations];

        FPSource *source = representedSource.source;

        if ([source.identifier isEqualToString:FPSourceImagesearch])
        {
            self.sourceController = [FPImageSearchSourceController new];
        }
        else
        {
            self.sourceController = [FPRemoteSourceController new];
        }

        self.sourceController.representedSource = representedSource;
        self.sourceController.delegate = self;

        [self loadCurrentPathAndInvalidateCache:YES];
    }
}

#pragma mark - Public Methods

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.loginButton.enabled = NO;
}

- (void)loadCurrentPathAndInvalidateCache:(BOOL)shouldInvalidate
{
    // Use this oportunity to refresh the browser view with 'no' items.

    self.sourceResultsController.items = nil;

    // Ask the source controller for content

    [self.sourceController fpLoadContentAtPath:shouldInvalidate];

    // Notify our delegate (if any) that the path has changed

    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(sourceViewController:pathChangedTo:)])
    {
        [self.delegate sourceViewController:self
                              pathChangedTo:self.representedSource.currentPath];
    }
}

- (void)loadPath:(NSString *)path
{
    [self loadPath:path andInvalidateCache:YES];
}

- (void)      loadPath:(NSString *)path
    andInvalidateCache:(BOOL)shouldInvalidateCache
{
    self.representedSource.currentPath = path;

    [self loadCurrentPathAndInvalidateCache:shouldInvalidateCache];
}

- (NSString *)currentPath
{
    return self.representedSource.currentPath;
}

- (NSArray *)selectedItems
{
    return self.sourceResultsController.selectedItems;
}

- (void)cancelAllOperations
{
    [self.representedSource cancelAllOperations];
}

#pragma mark - FPSourceResultsControllerDelegate Methods

- (void)       sourceResults:(FPSourceResultsController *)sourceResultsController
    didMomentarilySelectItem:(NSDictionary *)item
{
    FPSource *source = self.representedSource.source;

    if (source.overwritePossible)
    {
        NSString *filename = item[@"filename"];

        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(sourceViewController:didMomentarilySelectFilename:)])
        {
            [self.delegate sourceViewController:self
                   didMomentarilySelectFilename:filename];
        }
    }
}

- (void) sourceResults:(FPSourceResultsController *)sourceResultsController
    selectionDidChange:(NSArray *)selectedItems
{
    if (self.currentSelectionTextField)
    {
        NSString *selectionString;
        NSUInteger selectionCount = selectedItems.count;

        switch (selectionCount)
        {
            case 0:
                selectionString = @"No items selected";

                break;

            case 1:
                selectionString = [NSString stringWithFormat:@"%lu item selected", (unsigned long)selectionCount];

                break;

            default:
                selectionString = [NSString stringWithFormat:@"%lu items selected", (unsigned long)selectionCount];

                break;
        }

        self.currentSelectionTextField.stringValue = selectionString;
    }
}

- (void)          sourceResults:(FPSourceResultsController *)sourceResultsController
    wantsToEnterDirectoryAtPath:(NSString *)path
{
    [self loadPath:path];
}

- (void)sourceResultsWantsToGoUpOneDirectory:(FPSourceResultsController *)sourceResultsController
{
    FPRepresentedSource *representedSource = self.representedSource;

    if (![representedSource.currentPath isEqualToString:representedSource.parentPath])
    {
        [self loadPath:representedSource.parentPath];
    }
}

- (void)   sourceResults:(FPSourceResultsController *)sourceResultsController
    doubleClickedOnItems:(NSArray *)items
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(sourceViewController:doubleClickedOnItems:)])
    {
        [self.delegate sourceViewController:self
                       doubleClickedOnItems:items];
    }
}

#pragma mark - FPBaseSourceControllerDelegate Methods

- (void)sourceDidStartContentLoad:(FPBaseSourceController *)sender
{
    FPSourceTabView sourceTabView = self.displayStyleSegmentedControl.selectedSegment + 1;

    [self.tabView selectTabViewItemAtIndex:sourceTabView];
    [self.progressIndicator startAnimation:self];
}

- (void)          source:(FPBaseSourceController *)sender
    didFinishContentLoad:(id)content
{
    self.sourceResultsController.items = content;

    [self.progressIndicator stopAnimation:self];

    FPSource *source = self.representedSource.source;

    if (source.requiresAuth)
    {
        [self updateLoggedInStateInRepresentedSource:YES];
    }
}

- (void)          source:(FPBaseSourceController *)sender
    didReceiveNewContent:(id)content
{
    [self.sourceResultsController appendItems:content];

    [self.progressIndicator stopAnimation:self];
}

- (void)       sourceController:(FPBaseSourceController *)sender
    didFailContentLoadWithError:(NSError *)error
{
    DLog(@"Error loading content: %@", error);

    [self.progressIndicator stopAnimation:self];
}

#pragma mark - FPRemoteSourceControllerDelegate Methods

- (void)remoteSourceRequiresAuthentication:(FPRemoteSourceController *)sender
{
    [self.progressIndicator stopAnimation:self];
    [self.tabView selectTabViewItemAtIndex:FPAuthenticationTabView];
    [self updateLoggedInStateInRepresentedSource:NO];

    self.loginButton.enabled = YES;
}

#pragma mark - Actions

- (IBAction)login:(id)sender
{
    FPAuthSuccessBlock successBlock = ^{
        self.loginButton.enabled = NO;

        [self loadCurrentPathAndInvalidateCache:YES];
    };

    FPAuthFailureBlock failureBlock = ^(NSError *error) {
        self.loginButton.enabled = YES;

        [FPUtils presentError:error
              withMessageText:@"Response error"];
    };

    [self.authController displayAuthSheetWithSource:self.representedSource.source
                                      inModalWindow:self.view.window
                                      modalDelegate:self
                                     didEndSelector:@selector(authSheetDidEnd:returnCode:contextInfo:)
                                            success:successBlock
                                            failure:failureBlock];
}

- (IBAction)search:(id)sender
{
    if ([self.sourceController isKindOfClass:[FPImageSearchSourceController class]])
    {
        FPImageSearchSourceController *imageSearchSourceController = (FPImageSearchSourceController *)self.sourceController;

        imageSearchSourceController.searchString = [sender stringValue];

        [self loadCurrentPathAndInvalidateCache:YES];
    }
}

- (IBAction)changeDisplayStyle:(id)sender
{
    FPSourceTabView sourceTabView = self.displayStyleSegmentedControl.selectedSegment + 1;

    [self.tabView selectTabViewItemAtIndex:sourceTabView];
}

#pragma mark - Private Methods

- (void)authSheetDidEnd:(NSWindow *)sheet
             returnCode:(NSInteger)returnCode
            contextInfo:(void *)contextInfo
{
    // NO-OP
}

- (void)updateLoggedInStateInRepresentedSource:(BOOL)isLoggedIn
{
    FPRepresentedSource *representedSource = self.representedSource;

    if (isLoggedIn != representedSource.isLoggedIn)
    {
        representedSource.isLoggedIn = isLoggedIn;

        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(sourceViewController:representedSourceLoginStatusChanged:)])
        {
            [self.delegate sourceViewController:self
             representedSourceLoginStatusChanged:representedSource];
        }
    }
}

@end
