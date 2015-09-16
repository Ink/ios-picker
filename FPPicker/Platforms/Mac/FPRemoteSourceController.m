//
//  FPRemoteSourceController.m
//  FPPicker Mac
//
//  Created by Ruben Nine on 07/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPRemoteSourceController.h"
#import "FPInternalHeaders.h"
#import "FPLibrary.h"

@interface FPRemoteSourceController ()

@property (nonatomic, strong) NSString *nextPage;
@property (nonatomic, strong) FPRepresentedSource *representedSource;

@end

@implementation FPRemoteSourceController

#pragma mark - Public Methods

- (void)loadContentsAtPathInvalidatingCache:(BOOL)invalidateCache
{
    NSURLRequestCachePolicy cachePolicy = invalidateCache ? NSURLRequestReloadRevalidatingCacheData : NSURLRequestReturnCacheDataElseLoad;

    [self fpLoadContents:self.representedSource.currentPath
             cachePolicy:cachePolicy];
}

#pragma mark - Private Methods

- (void)fpLoadContents:(NSString *)loadpath
           cachePolicy:(NSURLRequestCachePolicy)policy
{
    [self.delegate sourceDidStartContentLoad:self];

    NSURLRequest *request = [FPLibrary requestForLoadPath:loadpath
                                               withFormat:@"info"
                                              queryString:nil
                                             andMimetypes:self.representedSource.source.mimetypes
                                              cachePolicy:policy];

    DLog(@"Loading Contents from URL: %@", request.URL);

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

    [self.representedSource.serialOperationQueue cancelAllOperations];
    [self.representedSource.serialOperationQueue addOperation:operation];
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
        [self.delegate sourceController:self
            didFailContentLoadWithError:error];
    }
}

- (void)fpLoadNextPage
{
    [self.delegate sourceDidStartContentLoad:self];

    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:self.representedSource.currentPath];

    NSArray *queryItems = @[
        [NSURLQueryItem queryItemWithName:@"start" value:[FPUtils urlEncodeString:self.nextPage]]
    ];

    if (urlComponents.queryItems)
    {
        urlComponents.queryItems = [urlComponents.queryItems arrayByAddingObjectsFromArray:queryItems];
    }
    else
    {
        urlComponents.queryItems = queryItems;
    }

    NSURLRequest *request = [FPLibrary requestForLoadPath:urlComponents.path
                                               withFormat:@"info"
                                              queryString:urlComponents.query
                                             andMimetypes:self.representedSource.source.mimetypes
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
            // Recursively load next pages...

            [self fpLoadNextPage];
        }
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        self.nextPage = nil;

        if (self.delegate)
        {
            [self.delegate sourceController:self
                didFailContentLoadWithError:error];
        }
        else
        {
            DLog(@"Error when performing operation %@: %@", operation, error);
        }
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    [self.representedSource.parallelOperationQueue addOperation:operation];
}

@end
