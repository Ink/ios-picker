//
//  FPSimpleAPI.m
//  FPPicker
//
//  NOTE: This API is in development and not yet ready to be used.
//
//  Created by Ruben Nine on 7/21/15.
//  Copyright (c) 2015 Filepicker.io. All rights reserved.
//

#import "FPSimpleAPI.h"
#import "FPSharedInternalHeaders.h"
#import "FPLibrary.h"

typedef void (^FPSimpleAPIPostAuthenticationActionBlock)();

@interface FPSimpleAPI ()

@property (nonatomic, strong) FPSource *source;

/*!
   Operation queue for content load requests.
 */
@property (nonatomic, strong) NSOperationQueue *contentLoadOperationQueue;

/*!
    Post authentication block.
 */
@property (nonatomic, strong) FPSimpleAPIPostAuthenticationActionBlock postAuthenticationActionBlock;

@end

@implementation FPSimpleAPI

#pragma mark - Accessors

- (NSOperationQueue *)contentLoadOperationQueue
{
    if (!_contentLoadOperationQueue)
    {
        _contentLoadOperationQueue = [NSOperationQueue new];
    }

    return _contentLoadOperationQueue;
}

#pragma mark - Constructors / Destructors

- (instancetype)initWithSource:(FPSource *)source
{
    self = [super init];

    if (self)
    {
        self.source = source;

        if (!self.source)
        {
            return nil;
        }

        [self registerForNotifications];
    }

    return self;
}

- (void)dealloc
{
    [self unregisterForNotifications];
}

#pragma mark - Public Methods

- (void)cancelPendingRequests
{
    [self.contentLoadOperationQueue cancelAllOperations];
}

- (void)getMediaListAtPath:(NSString *)path success:(FPSimpleAPIGetMediaListSuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure
{
    [self getMediaListAtPath:path
             withCachePolicy:NSURLRequestReturnCacheDataElseLoad
                     success:success
                     failure:failure];
}

- (void)getMediaListAtPath:(NSString *)path withCachePolicy:(NSURLRequestCachePolicy)cachePolicy success:(FPSimpleAPIGetMediaListSuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure
{
    NSString *sanitizedPath = [self sanitizeRelativePath:path];
    NSString *loadPath = [self.source.rootPath stringByAppendingString:sanitizedPath];

    NSURLRequest *request = [FPLibrary requestForLoadPath:loadPath
                                               withFormat:@"info"
                                             andMimetypes:self.source.mimetypes
                                              cachePolicy:cachePolicy];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        if (responseObject[@"auth"])
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(simpleAPI:requiresAuthenticationForSource:)])
            {
                __weak __typeof(self) weakSelf = self;

                self.postAuthenticationActionBlock = ^() {
                    [weakSelf getMediaListAtPath:path
                                 withCachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         success:success
                                         failure:failure];
                };

                [self.delegate simpleAPI:self
                 requiresAuthenticationForSource:self.source];
            }
            else
            {
                NSLog(@"Source %@ requires authentication and the delegate does not implement simpleAPI:requiresAuthenticationForSource: to handle it.", self.source.identifier);
            }

            return;
        }

        success(responseObject[@"contents"]);
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        failure(error);
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    [self.contentLoadOperationQueue cancelAllOperations];
    [self.contentLoadOperationQueue addOperation:operation];
}

/*!
   TODO: Implement
 */
- (void)getURLForMedia:(FPMediaInfo *)mediaInfo success:(FPSimpleAPISuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure progress:(FPSimpleAPIProgressBlock)progress
{
    return;
}

/*!
   TODO: Implement
 */
- (void)saveMedia:(FPMediaInfo *)mediaInfo atPath:(NSString *)path success:(FPSimpleAPISuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure
{
    return;
}

#pragma mark - Private Methods

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"auth"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock: ^(NSNotification *note) {
        if ([note.object isKindOfClass:[FPSource class]])
        {
            FPSource *source = (FPSource *)note.object;

            if ([source.identifier isEqualToString:self.source.identifier])
            {
                // Run post authentication block, if present
                if (self.postAuthenticationActionBlock)
                {
                    self.postAuthenticationActionBlock();
                    // ... and clear it afterwards
                    self.postAuthenticationActionBlock = nil;
                }
            }
        }
    }];
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)sanitizeRelativePath:(NSString *)relativePath
{
    NSString *sanitizedRelativePath;

    if ([relativePath characterAtIndex:0] == 47) // remove trailing slash if present
    {
        sanitizedRelativePath = [relativePath substringFromIndex:1];
    }
    else
    {
        sanitizedRelativePath = [relativePath copy];
    }

    return sanitizedRelativePath;
}

@end