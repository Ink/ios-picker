//
//  FPRemoteSourceController.m
//  FPPicker Mac
//
//  Created by Ruben Nine on 07/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPRemoteSourceController.h"
#import "FPSourceBrowserController.h"
#import "FPUtils+RequestHelpers.h"
#import "FPAuthController.h"
#import "FPInternalHeaders.h"
#import "FPSource.h"

typedef enum : NSUInteger
{
    FPAuthenticationTabView = 0,
    FPResultsTabView = 1
} FPSourceTabView;


@interface FPRemoteSourceController () <FPSourceBrowserControllerDelegate>

/*!
   Parallel operation queue.
   This operation queue (unlike FPAPIClient -operationQueue)
   supports unlimited simultaneous operations.
 */
@property (nonatomic, strong) NSOperationQueue *parallelOperationQueue;

/*!
   Serial operation queue.
   This operation queue is limited to 1 simultaneous operation.
 */
@property (nonatomic, strong) NSOperationQueue *serialOperationQueue;

@end

@implementation FPRemoteSourceController

#pragma mark - Accessors

- (NSOperationQueue *)parallelOperationQueue
{
    if (!_parallelOperationQueue)
    {
        _parallelOperationQueue = [NSOperationQueue new];
    }

    return _parallelOperationQueue;
}

- (NSOperationQueue *)serialOperationQueue
{
    if (!_serialOperationQueue)
    {
        _serialOperationQueue = [NSOperationQueue new];
        _serialOperationQueue.maxConcurrentOperationCount = 1;
    }

    return _serialOperationQueue;
}

- (void)setSource:(FPSource *)source
{
    _source = source;

    self.path = [NSString stringWithFormat:@"%@/", self.source.rootUrl];

    [self.serialOperationQueue cancelAllOperations];
    [self.parallelOperationQueue cancelAllOperations];
}

#pragma mark - Public Methods

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.loginButton.enabled = NO;
}

- (void)fpLoadContentAtPath
{
    [self fpLoadContents:self.path];
}

#pragma mark - FPSourceBrowserControllerDelegate Methods

- (void)sourceBrowserWantsToChangeCurrentPath:(NSString *)newPath
{
    self.path = newPath;

    [self fpLoadContentAtPath];
}

#pragma mark - Private Methods

- (void)fpLoadContents:(NSString *)loadpath
{
    [self fpLoadContents:loadpath
             cachePolicy:NSURLRequestReturnCacheDataElseLoad];
}

- (void)fpLoadContents:(NSString *)loadpath
           cachePolicy:(NSURLRequestCachePolicy)policy
{
    [self.progressIndicator startAnimation:self];

    NSURLRequest *request = [FPUtils requestForLoadPath:loadpath
                                               withType:@"info"
                                              mimetypes:self.source.mimetypes
                                            byAppending:@""
                                            cachePolicy:policy];

    NSLog(@"Loading Contents from URL: %@", request.URL);

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        [self fpLoadResponseSuccessAtPath:loadpath
                               withResult:responseObject];

        [self.progressIndicator stopAnimation:self];
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        [self fpLoadResponseFailureAtPath:loadpath
                                withError:error];

        [self.progressIndicator stopAnimation:self];
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    [self.serialOperationQueue cancelAllOperations];
    [self.serialOperationQueue addOperation:operation];
}

- (void)fpLoadResponseSuccessAtPath:(NSString *)loadPath
                         withResult:(id)JSON
{
    if (JSON[@"auth"])
    {
        [self.tabView selectTabViewItemAtIndex:FPAuthenticationTabView];

        self.loginButton.enabled = YES;

        return;
    }
    else
    {
        [self.tabView selectTabViewItemAtIndex:FPResultsTabView];
    }

    // Display results to the user

    self.sourceBrowserController.items = JSON[@"contents"];

    [self.sourceBrowserController.thumbnailListView reloadData];
}

- (void)fpLoadResponseFailureAtPath:(NSString *)loadPath
                          withError:(NSError *)error
{
    if (error.code == kCFURLErrorUserCancelledAuthentication)
    {
        [self fpLoadContents:loadPath
                 cachePolicy:NSURLRequestReloadIgnoringCacheData];
    }
    else if (error.code == kCFURLErrorCancelled)
    {
        // NO-OP
    }
    else
    {
        [self fpPresentError:error
             withMessageText:@"Response error"];
    }
}

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

#pragma mark - Actions

- (IBAction)login:(id)sender
{
    FPAuthSuccessBlock successBlock = ^{
        self.loginButton.enabled = NO;

        [self fpLoadContents:self.path
                 cachePolicy:NSURLRequestReloadRevalidatingCacheData];
    };

    FPAuthFailureBlock failureBlock = ^(NSError *error) {
        self.loginButton.enabled = YES;

        [self fpPresentError:error
             withMessageText:@"Response error"];
    };

    [self.authController displayAuthSheetWithSource:self.source
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
                           self.source.identifier];

    NSURL *url = [NSURL URLWithString:urlString];

    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:240];

    [self.progressIndicator startAnimation:self];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        [self fpLoadContents:self.path
                 cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];


        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

        for (NSString *urlString in self.source.externalDomains)
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

    [self.serialOperationQueue cancelAllOperations];
    [self.serialOperationQueue addOperation:operation];
}

@end
