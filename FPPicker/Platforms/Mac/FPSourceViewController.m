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


@interface FPSourceViewController () <FPSourceListControllerDelegate,
                                      FPSourceBrowserControllerDelegate,
                                      FPRemoteSourceControllerDelegate,
                                      FPNavigationControllerDelegate>

@property (nonatomic, strong) FPBaseSourceController *sourceController;

@end


@implementation FPSourceViewController

#pragma mark - Public Methods

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.loginButton.enabled = NO;
}

#pragma mark - FPSourceListControllerDelegate Methods

- (void)sourceListController:(FPSourceListController *)sourceListController
             didSelectSource:(FPSource *)source
{
    if ([source.identifier isEqualToString:@"filesystem"])
    {
        // TODO: Implement FPLocalFilesystemSourceController

        //self.sourceController = [FPLocalFilesystemSourceController new];
        self.sourceController = [FPRemoteSourceController new];
    }
    else if ([source.identifier isEqualToString:@"imagesearch"])
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
}

#pragma mark - FPNavigationControllerDelegate Methods

- (void)currentDirectoryPopupButtonSelectionChanged:(NSString *)newPath
{
    self.sourceController.path = newPath;

    [self.sourceController fpLoadContentAtPath:NO];
}

#pragma mark - FPSourceBrowserControllerDelegate Methods

- (void)          sourceBrowser:(FPSourceBrowserController *)sourceBrowserController
    wantsToPerformActionOnItems:(NSArray *)items
{
    if (items.count == 1)
    {
        NSDictionary *item = items[0];

        if ([item[@"is_dir"] boolValue])
        {
            self.sourceController.path = item[@"link_path"];

            [self.sourceController fpLoadContentAtPath:NO];
        }
    }
    else
    {
        DLog(@"User wants to perform an action on selected items %@", items);
    }
}

- (void)sourceBrowserWantsToGoUpOneDirectory:(FPSourceBrowserController *)sourceBrowserController
{
    if (self.sourceController.path.pathComponents.count > 3)
    {
        DLog(@"We need to go up one directory");

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
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:self.sourceBrowserController.items];

    [tempArray addObjectsFromArray:content];

    self.sourceBrowserController.items = [tempArray copy];
    [self.sourceBrowserController.thumbnailListView reloadData];
    [self.progressIndicator stopAnimation:self];
}

- (void)                 source:(FPBaseSourceController *)sender
    didFailContentLoadWithError:(NSError *)error
{
    DLog(@"Error loading content: %@", error);

    [self.progressIndicator stopAnimation:self];

    [self fpPresentError:error
         withMessageText:@"Request Error"];
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
    DLog(@"sender = %@", sender);

    if ([self.sourceController isKindOfClass:[FPImageSearchSourceController class]])
    {
        FPImageSearchSourceController *imageSearchSourceController = (FPImageSearchSourceController *)self.sourceController;

        imageSearchSourceController.searchString = [sender stringValue];

        DLog(@"imageSearchSourceController.searchString = %@", imageSearchSourceController.searchString);

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
