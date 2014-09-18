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

    [[NSNotificationCenter defaultCenter] postNotificationName:FPSourcePathDidChangeNotification
                                                        object:self.path];
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
            self.path = item[@"link_path"];

            [self fpLoadContentAtPath];
        }
    }
    else
    {
        DLog(@"User wants to perform an action on selected items %@", items);
    }
}

- (void)sourceBrowserWantsToGoUpOneDirectory:(FPSourceBrowserController *)sourceBrowserController
{
    if (self.path.pathComponents.count > 3)
    {
        DLog(@"We need to go up one directory");

        self.path = [[self.path stringByDeletingLastPathComponent] stringByAppendingString:@"/"];

        [self fpLoadContentAtPath];
    }
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

    id next = JSON[@"next"];

    if (next && next != [NSNull null])
    {
        if ([next respondsToSelector:@selector(stringValue)])
        {
            self.nextPage = [next stringValue];
        }
        else
        {
            self.nextPage = next;
        }
    }
    else
    {
        self.nextPage = nil;
    }

    if (self.nextPage)
    {
        [self fpLoadNextPage];
    }

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

- (void)fpLoadNextPage
{
    [self.progressIndicator startAnimation:self];

    NSString *nextPageParam = [NSString stringWithFormat:@"&start=%@", [FPUtils urlEncodeString:self.nextPage]];

    NSURLRequest *request = [self fpRequestForLoadPath:self.path
                                            withFormat:@"info"
                                           byAppending:nextPageParam
                                           cachePolicy:NSURLRequestReloadIgnoringCacheData];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:self.sourceBrowserController.items];

        [tempArray addObjectsFromArray:responseObject[@"contents"]];

        self.sourceBrowserController.items = [tempArray copy];

        tempArray = nil;

        id next = responseObject[@"next"];

        if (next && next != [NSNull null])
        {
            if ([next respondsToSelector:@selector(stringValue)])
            {
                self.nextPage = [next stringValue];
            }
            else
            {
                self.nextPage = next;
            }
        }
        else
        {
            self.nextPage = nil;
        }

        if (self.nextPage)
        {
            [self fpLoadNextPage];
        }

        [self.sourceBrowserController.thumbnailListView reloadData];
        [self.progressIndicator stopAnimation:self];
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        DLog(@"Error: %@", error);

        self.nextPage = nil;

        [self.sourceBrowserController.thumbnailListView reloadData];
        [self.progressIndicator stopAnimation:self];
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    [self.parallelOperationQueue addOperation:operation];
}

- (NSURLRequest *)fpRequestForLoadPath:(NSString *)loadpath
                            withFormat:(NSString *)type
                           byAppending:(NSString *)additionalString
                           cachePolicy:(NSURLRequestCachePolicy)policy
{
    FPSession *fpSession = [FPSession new];

    fpSession.APIKey = fpAPIKEY;
    fpSession.mimetypes = self.source.mimetypes;

    NSString *escapedSessionString = [FPUtils urlEncodeString:[fpSession JSONSessionString]];

    NSMutableString *urlString = [NSMutableString stringWithString:[fpBASE_URL stringByAppendingString:[@"/api/path" stringByAppendingString : loadpath]]];

    if ([urlString rangeOfString:@"?"].location == NSNotFound)
    {
        [urlString appendFormat:@"?format=%@&%@=%@", type, @"js_session", escapedSessionString];
    }
    else
    {
        [urlString appendFormat:@"&format=%@&%@=%@", type, @"js_session", escapedSessionString];
    }

    [urlString appendString:additionalString];

    //NSLog(@"Loading Contents from URL: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];


    NSMutableURLRequest *mrequest = [NSMutableURLRequest requestWithURL:url
                                                            cachePolicy:policy
                                                        timeoutInterval:240];

    [mrequest setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:fpCOOKIES]];

    return mrequest;
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
