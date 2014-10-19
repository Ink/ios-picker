//
//  FPSourceViewController.m
//  FPPicker
//
//  Created by Ruben on 9/25/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPSourceViewController.h"
#import "FPSourceListController.h"
#import "FPSourceBrowserController.h"
#import "FPRemoteSourceController.h"
#import "FPImageSearchSourceController.h"
#import "FPNavigationController.h"
#import "FPAuthController.h"
#import "FPInternalHeaders.h"

typedef enum : NSUInteger
{
    FPAuthenticationTabView = 0,
    FPResultsTabView = 1
} FPSourceTabView;


@interface FPSourceViewController () <FPSourceBrowserControllerDelegate,
                                      FPRemoteSourceControllerDelegate>

@property (readwrite, nonatomic) FPBaseSourceController *sourceController;

@end


@implementation FPSourceViewController

#pragma mark - Accessors

- (void)setAllowsFileSelection:(BOOL)allowsFileSelection
{
    _allowsFileSelection = allowsFileSelection;

    self.sourceBrowserController.allowsFileSelection = allowsFileSelection;

    [self.currentSelectionTextField setHidden:!allowsFileSelection];
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _allowsMultipleSelection = allowsMultipleSelection;

    self.sourceBrowserController.allowsMultipleSelection = allowsMultipleSelection;
}

- (void)setRepresentedSource:(FPRepresentedSource *)representedSource
{
    _representedSource = representedSource;

    [self cancelAllOperations];

    FPSource *source = representedSource.source;

    if ([source.identifier isEqualToString:@"imagesearch"])
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

#pragma mark - Public Methods

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.loginButton.enabled = NO;
}

- (void)loadCurrentPathAndInvalidateCache:(BOOL)shouldInvalidate
{
    [self.sourceController fpLoadContentAtPath:shouldInvalidate];

    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(sourceViewController:pathChangedTo:)])
    {
        [self.delegate sourceViewController:self
                              pathChangedTo:self.sourceController.representedSource.currentPath];
    }
}

- (void)loadPath:(NSString *)path
{
    self.sourceController.representedSource.currentPath = path;

    [self loadCurrentPathAndInvalidateCache:YES];
}

- (NSString *)currentPath
{
    return self.sourceController.representedSource.currentPath;
}

- (NSArray *)selectedItems
{
    return self.sourceBrowserController.selectedItems;
}

- (void)cancelAllOperations
{
    [self.sourceController.representedSource cancelAllOperations];
}

#pragma mark - FPSourceBrowserControllerDelegate Methods

- (void)       sourceBrowser:(FPSourceBrowserController *)sourceBrowserController
    didMomentarilySelectItem:(NSDictionary *)item
{
    FPSource *source = self.sourceController.representedSource.source;

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

- (void) sourceBrowser:(FPSourceBrowserController *)sourceBrowserController
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

- (void)          sourceBrowser:(FPSourceBrowserController *)sourceBrowserController
    wantsToEnterDirectoryAtPath:(NSString *)path
{
    self.sourceController.representedSource.currentPath = path;

    [self loadCurrentPathAndInvalidateCache:NO];
}

- (void)sourceBrowserWantsToGoUpOneDirectory:(FPSourceBrowserController *)sourceBrowserController
{
    if (self.sourceController.representedSource.currentPath.pathComponents.count > 3)
    {
        self.sourceController.representedSource.currentPath = [[self.sourceController.representedSource.currentPath stringByDeletingLastPathComponent] stringByAppendingString:@"/"];

        [self loadCurrentPathAndInvalidateCache:NO];
    }
}

- (void)   sourceBrowser:(FPSourceBrowserController *)sourceBrowserController
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
    [self.progressIndicator startAnimation:self];
}

- (void)          source:(FPBaseSourceController *)sender
    didFinishContentLoad:(id)content
{
    self.sourceBrowserController.items = content;
    [self.sourceBrowserController.browserView reloadData];

    [self.tabView selectTabViewItemAtIndex:FPResultsTabView];
    [self.progressIndicator stopAnimation:self];

    FPSource *source = self.sourceController.representedSource.source;

    if (source.requiresAuth)
    {
        [self updateLoggedInStateInRepresentedSource:YES];
    }
}

- (void)          source:(FPBaseSourceController *)sender
    didReceiveNewContent:(id)content
{
    self.sourceBrowserController.items = [self.sourceBrowserController.items arrayByAddingObjectsFromArray:content];

    [self.sourceBrowserController.browserView reloadData];
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

    [self.authController displayAuthSheetWithSource:self.sourceController.representedSource.source
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

#pragma mark - Private Methods

- (void)authSheetDidEnd:(NSWindow *)sheet
             returnCode:(NSInteger)returnCode
            contextInfo:(void *)contextInfo
{
    // NO-OP
}

- (void)updateLoggedInStateInRepresentedSource:(BOOL)isLoggedIn
{
    FPRepresentedSource *representedSource = self.sourceController.representedSource;

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
