//
//  FPRemoteSourceController.m
//  FPPicker Mac
//
//  Created by Ruben Nine on 07/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPRemoteSourceController.h"
#import "FPUtils+RequestHelpers.h"
#import "FPInternalHeaders.h"

@interface FPRemoteSourceController ()

@end

@implementation FPRemoteSourceController

#pragma mark - Public Methods

- (void)fpLoadContentAtPath:(BOOL)force
{
    NSURLRequestCachePolicy cachePolicy = force ? NSURLRequestReloadRevalidatingCacheData : NSURLRequestReturnCacheDataElseLoad;

    [self fpLoadContents:self.path
             cachePolicy:cachePolicy];

    [[NSNotificationCenter defaultCenter] postNotificationName:FPSourcePathDidChangeNotification
                                                        object:self.path];
}

#pragma mark - Private Methods

- (void)fpLoadContents:(NSString *)loadpath
           cachePolicy:(NSURLRequestCachePolicy)policy
{
    [self.delegate sourceDidStartContentLoad:self];

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
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        [self fpLoadResponseFailureAtPath:loadpath
                                withError:error];
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
        if (self.delegate)
        {
            [self.delegate remoteSourceRequiresAuthentication:self];
        }

        return;
    }
    else
    {
        // Display results to the user

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

        if (self.delegate)
        {
            [self.delegate source:self
             didFinishContentLoad:JSON[@"contents"]];
        }
    }
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
        [self.delegate source:self
         didFailContentLoadWithError:error];
    }
}

- (void)fpLoadNextPage
{
    [self.delegate sourceDidStartContentLoad:self];

    NSString *nextPageParam = [NSString stringWithFormat:@"&start=%@", [FPUtils urlEncodeString:self.nextPage]];

    NSURLRequest *request = [self fpRequestForLoadPath:self.path
                                            withFormat:@"info"
                                           byAppending:nextPageParam
                                           cachePolicy:NSURLRequestReloadIgnoringCacheData];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        [self.delegate source:self
         didReceiveNewContent:responseObject[@"contents"]];

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
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        DLog(@"Error: %@", error);

        self.nextPage = nil;

        [self.delegate source:self
         didFailContentLoadWithError:error];
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
        [urlString appendString:@"?"];
    }
    else
    {
        [urlString appendFormat:@"&"];
    }

    [urlString appendFormat:@"format=%@&%@=%@", type, @"js_session", escapedSessionString];
    [urlString appendString:additionalString];

    NSURL *url = [NSURL URLWithString:urlString];


    NSMutableURLRequest *mrequest = [NSMutableURLRequest requestWithURL:url
                                                            cachePolicy:policy
                                                        timeoutInterval:240];

    [mrequest setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:fpCOOKIES]];

    return mrequest;
}

@end
