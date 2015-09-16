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
#import "FPUtils.h"
#import <AFNetworking/AFNetworking.h>

typedef void (^FPSimpleAPIPostAuthenticationActionBlock)();

@interface FPSimpleAPI ()

@property (nonatomic, strong, nonnull) FPSource *source;

/*!
   The operation queue to use for any requests to the REST API.
 */
@property (nonatomic, strong, nonnull) NSOperationQueue *operationQueue;

/*!
    Post authentication block.
 */
@property (nonatomic, strong, nullable) FPSimpleAPIPostAuthenticationActionBlock postAuthenticationActionBlock;

@end

@implementation FPSimpleAPI

#pragma mark - Accessors

- (NSOperationQueue *)operationQueue
{
    if (!_operationQueue)
    {
        _operationQueue = [NSOperationQueue new];
    }

    return _operationQueue;
}

#pragma mark - Class Methods

+ (FPSimpleAPI *)simpleAPIWithSource:(FPSource *)source
{
    return [[FPSimpleAPI alloc] initWithSource:source];
}

#pragma mark - Constructors / Destructors

- (instancetype)initWithSource:(FPSource *)source
{
    self = [super init];

    if (self)
    {
        self.source = source;
        [self registerForNotifications];
    }

    return self;
}

- (void)dealloc
{
    [self cancelAllRequests];
    [self unregisterForNotifications];
}

#pragma mark - Public Methods

- (void)suspendAllRequests
{
    self.operationQueue.suspended = YES;
}

- (void)resumeAllRequests
{
    self.operationQueue.suspended = NO;
}

- (void)cancelAllRequests
{
    [self.operationQueue cancelAllOperations];
}

- (void)getMediaListAtPath:(NSString *)path completion:(FPSimpleAPIMediaListCompletionBlock)completion
{
    NSMutableArray *mediaList = [NSMutableArray array];

    [self recursiveGetMediaListAtPath:path
                       partialResults:mediaList
                            startPage:0
                           completion:completion];
}

- (void)getMediaListAtPath:(NSString *)path startPage:(NSUInteger)startPage completion:(FPSimpleAPIMediaListCompletionBlock)completion
{
    [self getMediaListAtPath:path
                   startPage:startPage
             withCachePolicy:NSURLRequestReturnCacheDataElseLoad
                  completion:completion];
}

- (void)getMediaInfoAtPath:(NSString *)path completion:(FPSimpleAPIMediaCompletionBlock)completion progress:(FPSimpleAPIProgressBlock)progress
{
    FPFetchObjectSuccessBlock successBlock = ^(FPMediaInfo *mediaInfo) {
        if (completion)
        {
            completion(mediaInfo, nil);
        }
    };

    FPFetchObjectFailureBlock failureBlock = ^(NSError *error) {
        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];

        // NOTE: The REST API does not currently give a 401 response when auth is required.
        // In this case, when auth credentials are required but missing it simply fails with
        // a 500 response. So, until that changes, we are *unaccurately* threating 500 as 401.

        switch (response.statusCode)
        {
            case 401:
            case 500: {
                __weak __typeof(self) weakSelf = self;

                self.postAuthenticationActionBlock = ^() {
                    [weakSelf getMediaInfoAtPath:path
                                      completion:completion
                                        progress:progress];
                };

                [self requestAuthenticationFromDelegate];

                return;
            }
            default:
                break;
        }

        if (completion)
        {
            completion(nil, error);
        }
    };

    FPFetchObjectProgressBlock progressBlock = ^(float value) {
        if (progress)
        {
            progress(value);
        }
    };

    NSDictionary *obj = @{@"link_path":path};

    [FPLibrary requestObjectMediaInfo:obj
                           withSource:self.source
                  usingOperationQueue:self.operationQueue
                              success:successBlock
                              failure:failureBlock
                             progress:progressBlock];
}

- (void)saveMediaAtLocalURL:(NSURL *)localURL named:(NSString *)name withMimeType:(NSString *)mimetype atPath:(NSString *)path completion:(FPSimpleAPIMediaCompletionBlock)completion progress:(FPSimpleAPIProgressBlock)progress
{
    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        if (completion)
        {
            FPMediaInfo *mediaInfo = [FPMediaInfo new];

            mediaInfo.mediaType = [FPUtils UTIForMimetype:mimetype];
            mediaInfo.mediaURL = localURL;
            mediaInfo.remoteURL = [NSURL URLWithString:JSON[@"url"]];
            mediaInfo.filename = JSON[@"filename"];
            mediaInfo.filesize = @([FPUtils fileSizeForLocalURL:localURL]);
            mediaInfo.key = name;
            mediaInfo.source = self.source;

            completion(mediaInfo, nil);
        }
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];

        // NOTE: The REST API does not currently give a 401 response when auth is required.
        // In this case, when auth credentials are required but missing it simply fails with
        // a 200 text/html response.
        // So, until that changes, we are *unaccurately* threating 200 text/html as 401.

        switch (response.statusCode)
        {
            case 401:
            case 200: {
                if ([response.MIMEType isEqualToString:@"text/html"])
                {
                    __weak __typeof(self) weakSelf = self;

                    self.postAuthenticationActionBlock = ^() {
                        [weakSelf saveMediaAtLocalURL:localURL
                                                named:name
                                         withMimeType:mimetype
                                               atPath:path
                                           completion:completion
                                             progress:progress];
                    };

                    [self requestAuthenticationFromDelegate];

                    return;
                }
            }
            default:
                break;
        }

        if (completion)
        {
            completion(nil, error);
        }
    };

    FPUploadAssetProgressBlock progressBlock = ^(float value) {
        if (progress)
        {
            progress(value);
        }
    };

    NSString *fullSourcePath = [self.source fullSourcePathForRelativePath:path];

    [FPLibrary uploadDataURL:localURL
                       named:name
                      toPath:fullSourcePath
                  ofMimetype:mimetype
         usingOperationQueue:self.operationQueue
                     success:successBlock
                     failure:failureBlock
                    progress:progressBlock];
}

- (void)saveMediaRepresentedByData:(NSData *)data named:(NSString *)name withMimeType:(NSString *)mimetype atPath:(NSString *)path completion:(FPSimpleAPIMediaCompletionBlock)completion progress:(FPSimpleAPIProgressBlock)progress
{
    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        if (completion)
        {
            FPMediaInfo *mediaInfo = [FPMediaInfo new];

            mediaInfo.mediaType = [FPUtils UTIForMimetype:mimetype];
            mediaInfo.remoteURL = [NSURL URLWithString:JSON[@"url"]];
            mediaInfo.filename = JSON[@"filename"];
            mediaInfo.filesize = @(data.length);
            mediaInfo.key = name;
            mediaInfo.source = self.source;

            completion(mediaInfo, nil);
        }
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];

        // NOTE: The REST API does not currently give a 401 response when auth is required.
        // In this case, when auth credentials are required but missing it simply fails with
        // a 200 text/html response.
        // So, until that changes, we are *unaccurately* threating 200 text/html as 401.

        switch (response.statusCode)
        {
            case 401:
            case 200: {
                if ([response.MIMEType isEqualToString:@"text/html"])
                {
                    __weak __typeof(self) weakSelf = self;

                    self.postAuthenticationActionBlock = ^() {
                        [weakSelf saveMediaRepresentedByData:data
                                                       named:name
                                                withMimeType:mimetype
                                                      atPath:path
                                                  completion:completion
                                                    progress:progress];
                    };

                    [self requestAuthenticationFromDelegate];

                    return;
                }
            }
            default:
                break;
        }

        if (completion)
        {
            completion(nil, error);
        }
    };

    FPUploadAssetProgressBlock progressBlock = ^(float value) {
        progress(value);
    };

    NSString *fullSourcePath = [self.source fullSourcePathForRelativePath:path];

    [FPLibrary uploadData:data
                    named:name
                   toPath:fullSourcePath
               ofMimetype:mimetype
      usingOperationQueue:self.operationQueue
                  success:successBlock
                  failure:failureBlock
                 progress:progressBlock];
}

- (void)saveMediaInfo:(FPMediaInfo *)mediaInfo named:(NSString *)name atPath:(NSString *)path completion:(FPSimpleAPIMediaCompletionBlock)completion progress:(FPSimpleAPIProgressBlock)progress
{
    FPSimpleAPIMediaCompletionBlock completionBlock = ^(FPMediaInfo *uploadedMediaInfo, NSError *error) {
        if (uploadedMediaInfo)
        {
            uploadedMediaInfo.originalAsset = mediaInfo.originalAsset;
        }

        if (completion)
        {
            completion(uploadedMediaInfo, error);
        }
    };

    return [self saveMediaAtLocalURL:mediaInfo.mediaURL
                               named:name
                        withMimeType:mediaInfo.MIMEtype
                              atPath:path
                          completion:completionBlock
                            progress:progress];
}

#pragma mark - Private Methods

- (void)requestAuthenticationFromDelegate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(simpleAPI:requiresAuthenticationForSource:)])
    {
        [self.delegate simpleAPI:self
         requiresAuthenticationForSource:self.source];
    }
    else
    {
        NSForceLog(@"Source `%@` requires authentication but the delegate does not implement `-simpleAPI:requiresAuthenticationForSource: to handle it.`", self.source.identifier);
    }
}

- (void)getMediaListAtPath:(NSString *)path startPage:(NSUInteger)startPage withCachePolicy:(NSURLRequestCachePolicy)cachePolicy completion:(FPSimpleAPIMediaListCompletionBlock)completion
{
    NSString *fullSourcePath = [self.source fullSourcePathForRelativePath:path];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:fullSourcePath];

    urlComponents.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"start"
                                    value:@(startPage).stringValue]
    ];

    NSURLRequest *request = [FPLibrary requestForLoadPath:urlComponents.path
                                               withFormat:@"info"
                                              queryString:urlComponents.query
                                             andMimetypes:self.source.mimetypes
                                              cachePolicy:cachePolicy];

    AFRequestOperationSuccessBlock successOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             id responseObject) {
        if (responseObject[@"auth"])
        {
            __weak __typeof(self) weakSelf = self;

            self.postAuthenticationActionBlock = ^() {
                [weakSelf getMediaListAtPath:path
                                   startPage:startPage
                             withCachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                  completion:completion];
            };

            [self requestAuthenticationFromDelegate];

            return;
        }

        id nextObject = responseObject[@"next"];
        NSUInteger nextPageNumber = 0;

        if (nextObject && nextObject != [NSNull null])
        {
            nextPageNumber = [responseObject[@"next"] unsignedIntegerValue];
        }

        if (completion)
        {
            completion(responseObject[@"contents"], nextPageNumber, nil);
        }
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        if (completion)
        {
            completion(nil, 0, error);
        }
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    [self.operationQueue addOperation:operation];
}

- (void)recursiveGetMediaListAtPath:(NSString *)path partialResults:(NSMutableArray *)partialResults startPage:(NSUInteger)startPage completion:(FPSimpleAPIMediaListCompletionBlock)completion
{
    [self getMediaListAtPath:path
                   startPage:startPage
                  completion: ^(NSArray * mediaList, NSUInteger nextPage, NSError *error) {
        if (error)
        {
            completion(nil, 0, error);
        }
        else
        {
            [partialResults addObjectsFromArray:mediaList];

            if (nextPage > 0)
            {
                [self recursiveGetMediaListAtPath:path
                                   partialResults:partialResults
                                        startPage:nextPage
                                       completion:completion];
            }
            else
            {
                if (completion)
                {
                    completion([partialResults copy], 0, nil);
                }
            }
        }
    }];
}

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserverForName:FPPickerDidAuthenticateAgainstSourceNotification
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

@end
