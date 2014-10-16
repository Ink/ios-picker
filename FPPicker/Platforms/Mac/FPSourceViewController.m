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
#import "FPPickerController.h"
#import "FPFileTransferWindowController.h"
#import "FPInternalHeaders.h"

typedef enum : NSUInteger
{
    FPAuthenticationTabView = 0,
    FPResultsTabView = 1
} FPSourceTabView;


@interface FPSourceViewController () <FPSourceListControllerDelegate,
                                      FPSourceBrowserControllerDelegate,
                                      FPRemoteSourceControllerDelegate,
                                      FPNavigationControllerDelegate,
                                      FPFileTransferWindowControllerDelegate>

@property (nonatomic, weak) IBOutlet NSScrollView *scrollView;
@property (nonatomic, strong) FPBaseSourceController *sourceController;

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

#pragma mark - Public Methods

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.loginButton.enabled = NO;
}

- (BOOL)pickSelectedItems
{
    // Validate selection by looking for directories

    for (NSDictionary *item in self.sourceBrowserController.selectedItems)
    {
        if ([item[@"is_dir"] boolValue])
        {
            // Display alert with error

            NSError *error = [FPUtils errorWithCode:200
                              andLocalizedDescription:@"Selection must not contain any directories."];

            [self fpPresentError:error
                 withMessageText:@"Selection error"];

            return NO;
        }
    }

    FPFileTransferWindowController *fileTransferController = [FPFileTransferWindowController new];

    fileTransferController.delegate = self;
    fileTransferController.sourceController = self.sourceController;

    [fileTransferController enqueueItems:self.sourceBrowserController.selectedItems];
    [fileTransferController process];

    return YES;
}

- (void)cancelAllOperations
{
    [self.sourceController cancelAllOperations];
}

#pragma mark - FPFileTransferWindowControllerDelegate Methods

- (BOOL)FPFileTransferController:(FPFileTransferWindowController *)fileTransferWindowController
         shouldPickMediaWithInfo:(FPMediaInfo *)info
{
    if (self.pickerController.delegate &&
        [self.pickerController.delegate respondsToSelector:@selector(FPPickerController:shouldPickMediaWithInfo:)])
    {
        return [self.pickerController.delegate FPPickerController:self.pickerController
                                          shouldPickMediaWithInfo:info];
    }

    return YES;
}

- (void)FPFileTransferController:(FPFileTransferWindowController *)fileTransferWindowController
       didFinishDownloadingItems:(NSArray *)items
{
    DLog(@"Got items: %@", @(items.count));

    if (self.pickerController.delegate &&
        [self.pickerController.delegate respondsToSelector:@selector(FPPickerController:didFinishPickingMultipleMediaWithResults:)])
    {
        [self.pickerController.delegate FPPickerController:self.pickerController
                  didFinishPickingMultipleMediaWithResults:items];
    }
}

- (void)FPFileTransferControllerDidCancelDownloadingItems:(FPFileTransferWindowController *)fileTransferWindowController
{
    if (self.pickerController.delegate &&
        [self.pickerController.delegate respondsToSelector:@selector(FPPickerControllerDidCancel:)])
    {
        [self.pickerController.delegate FPPickerControllerDidCancel:self.pickerController];
    }
}

- (BOOL)FPFileTransferControllerShouldDownload:(FPFileTransferWindowController *)fileTransferWindowController
{
    return self.pickerController.shouldDownload;
}

- (BOOL)FPFileTransferControllerShouldUpload:(FPFileTransferWindowController *)fileTransferWindowController
{
    return self.pickerController.shouldUpload;
}

#pragma mark - FPSourceListControllerDelegate Methods

- (void)sourceListController:(FPSourceListController *)sourceListController
             didSelectSource:(FPSource *)source
{
    [self cancelAllOperations];

    if ([source.identifier isEqualToString:@"imagesearch"])
    {
        self.sourceController = [FPImageSearchSourceController new];
    }
    else
    {
        self.sourceController = [FPRemoteSourceController new];
    }

    self.sourceController.source = source;
    self.sourceController.delegate = self;

    self.navigationController.shouldEnableControls = self.sourceController.navigationSupported;
    self.searchField.stringValue = @"";

    [self.searchField setHidden:!self.sourceController.searchSupported];

    [self.sourceController fpLoadContentAtPath:YES];


    // Scroll to top

    NSPoint pt = NSMakePoint(0.0, NSMaxY([self.scrollView.documentView bounds]));

    [self.scrollView.documentView scrollPoint:pt];
}

#pragma mark - FPNavigationControllerDelegate Methods

- (void)currentDirectoryPopupButtonSelectionChanged:(NSString *)newPath
{
    self.sourceController.path = newPath;

    [self.sourceController fpLoadContentAtPath:NO];
}

#pragma mark - FPSourceBrowserControllerDelegate Methods

- (void)       sourceBrowser:(FPSourceBrowserController *)sourceBrowserController
    didMomentarilySelectItem:(NSDictionary *)item
{
    if (self.filenameTextField &&
        self.sourceController.source.overwritePossible)
    {
        self.filenameTextField.stringValue = item[@"filename"];
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
    self.sourceController.path = path;

    [self.sourceController fpLoadContentAtPath:NO];
}

- (void)sourceBrowserWantsToGoUpOneDirectory:(FPSourceBrowserController *)sourceBrowserController
{
    if (self.sourceController.path.pathComponents.count > 3)
    {
        self.sourceController.path = [[self.sourceController.path stringByDeletingLastPathComponent] stringByAppendingString:@"/"];

        [self.sourceController fpLoadContentAtPath:NO];
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

    [self.sourceBrowserController.thumbnailListView reloadData];
    [self.tabView selectTabViewItemAtIndex:FPResultsTabView];
    [self.progressIndicator stopAnimation:self];
}

- (void)          source:(FPBaseSourceController *)sender
    didReceiveNewContent:(id)content
{
    self.sourceBrowserController.items = [self.sourceBrowserController.items arrayByAddingObjectsFromArray:content];

    [self.sourceBrowserController.thumbnailListView reloadData];
    [self.progressIndicator stopAnimation:self];
}

- (void)                 source:(FPBaseSourceController *)sender
    didFailContentLoadWithError:(NSError *)error
{
    DLog(@"Error loading content: %@", error);

    [self.progressIndicator stopAnimation:self];
}

#pragma mark - FPRemoteSourceControllerDelegate Methods

- (void)remoteSourceRequiresAuthentication:(FPRemoteSourceController *)sender
{
    [self.tabView selectTabViewItemAtIndex:FPAuthenticationTabView];

    self.loginButton.enabled = YES;
}

#pragma mark - Actions

- (IBAction)login:(id)sender
{
    FPAuthSuccessBlock successBlock = ^{
        self.loginButton.enabled = NO;

        [self.sourceController fpLoadContentAtPath:YES];
    };

    FPAuthFailureBlock failureBlock = ^(NSError *error) {
        self.loginButton.enabled = YES;

        [self fpPresentError:error
             withMessageText:@"Response error"];
    };

    [self.authController displayAuthSheetWithSource:self.sourceController.source
                                      inModalWindow:self.view.window
                                      modalDelegate:self
                                     didEndSelector:@selector(authSheetDidEnd:returnCode:contextInfo:)
                                            success:successBlock
                                            failure:failureBlock];
}

- (IBAction)logout:(id)sender
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/client/%@/unauth",
                           fpBASE_URL,
                           self.sourceController.source.identifier];

    NSURL *url = [NSURL URLWithString:urlString];

    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:240];

    [self.progressIndicator startAnimation:self];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        [self.sourceController fpLoadContentAtPath:YES];

        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

        for (NSString *urlString in self.sourceController.source.externalDomains)
        {
            NSArray *siteCookies;
            siteCookies = [cookieStorage cookiesForURL:[NSURL URLWithString:urlString]];

            for (NSHTTPCookie *cookie in siteCookies)
            {
                [cookieStorage deleteCookie:cookie];
            }
        }

        [self.progressIndicator stopAnimation:self];
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        [self.progressIndicator stopAnimation:self];

        [self fpPresentError:error
             withMessageText:@"Logout failure"];
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    [self.sourceController.serialOperationQueue cancelAllOperations];
    [self.sourceController.serialOperationQueue addOperation:operation];
}

- (IBAction)search:(id)sender
{
    if ([self.sourceController isKindOfClass:[FPImageSearchSourceController class]])
    {
        FPImageSearchSourceController *imageSearchSourceController = (FPImageSearchSourceController *)self.sourceController;

        imageSearchSourceController.searchString = [sender stringValue];

        [self.sourceController fpLoadContentAtPath:YES];
    }
}

#pragma mark - Private Methods

- (void)fpPresentError:(NSError *)error
       withMessageText:(NSString *)messageText
{
    NSAlert *alert = [NSAlert alertWithMessageText:messageText
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"%@", error.localizedDescription];

    [alert runModal];
}

- (void)authSheetDidEnd:(NSWindow *)sheet
             returnCode:(NSInteger)returnCode
            contextInfo:(void *)contextInfo
{
    // NO-OP
}

@end
