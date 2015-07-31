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
    [self unregisterForNotifications];
}

#pragma mark - Public Methods

- (void)cancelAllRequests
{
    [self.operationQueue cancelAllOperations];
}

- (void)getMediaListAtPath:(NSString *)path success:(FPSimpleAPIGetMediaListSuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure
{
    NSMutableArray *mediaList = [NSMutableArray array];

    [self recursiveGetMediaListAtPath:path
                       partialResults:mediaList
                            startPage:0
                              success:success
                              failure:failure];
}

- (void)getMediaListAtPath:(NSString *)path startPage:(NSUInteger)startPage success:(FPSimpleAPIGetMediaListSuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure
{
    [self getMediaListAtPath:path
                   startPage:startPage
             withCachePolicy:NSURLRequestReturnCacheDataElseLoad
                     success:success
                     failure:failure];
}

- (void)getMediaListAtPath:(NSString *)path startPage:(NSUInteger)startPage withCachePolicy:(NSURLRequestCachePolicy)cachePolicy success:(FPSimpleAPIGetMediaListSuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure
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
                                     success:success
                                     failure:failure];
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

        if (success)
        {
            success(responseObject[@"contents"], nextPageNumber);
        }
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        if (failure)
        {
            failure(error);
        }
    };

    AFHTTPRequestOperation *operation;

    operation = [[FPAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                    success:successOperationBlock
                                                                    failure:failureOperationBlock];

    [self.operationQueue addOperation:operation];
}

- (void)getMediaInfoAtPath:(NSString *)path success:(FPSimpleAPIGetMediaSuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure progress:(FPSimpleAPIProgressBlock)progress
{
    FPFetchObjectSuccessBlock successBlock = ^(FPMediaInfo *mediaInfo) {
        if (success)
        {
            success(mediaInfo);
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
                                         success:success
                                         failure:failure
                                        progress:progress];
                };

                [self requestAuthenticationFromDelegate];

                return;
            }
            default:
                break;
        }

        if (failure)
        {
            failure(error);
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
                       shouldDownload:YES
                              success:successBlock
                              failure:failureBlock
                             progress:progressBlock];
}

- (void)saveMediaAtLocalURL:(NSURL *)localURL named:(NSString *)name withMimeType:(NSString *)mimetype atPath:(NSString *)path success:(FPSimpleAPIUploadSuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure progress:(FPSimpleAPIProgressBlock)progress
{
    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        if (success)
        {
            DLog(@"JSON = %@", JSON);


            FPMediaInfo *mediaInfo = [FPMediaInfo new];

            mediaInfo.mediaType = [FPUtils UTIForMimetype:mimetype];
            mediaInfo.mediaURL = localURL;
            mediaInfo.remoteURL = [NSURL URLWithString:JSON[@"url"]];
            mediaInfo.filename = JSON[@"filename"];
            mediaInfo.filesize = @([FPUtils fileSizeForLocalURL:localURL]);
            mediaInfo.key = name;
            mediaInfo.source = self.source;

            success(mediaInfo);
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
                                              success:success
                                              failure:failure
                                             progress:progress];
                    };

                    [self requestAuthenticationFromDelegate];

                    return;
                }
            }
            default:
                break;
        }

        if (failure)
        {
            failure(error);
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

- (void)saveMediaRepresentedByData:(NSData *)data named:(NSString *)name withMimeType:(NSString *)mimetype atPath:(NSString *)path success:(FPSimpleAPIUploadSuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure progress:(FPSimpleAPIProgressBlock)progress
{
    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        if (success)
        {
            FPMediaInfo *mediaInfo = [FPMediaInfo new];

            mediaInfo.mediaType = [FPUtils UTIForMimetype:mimetype];
            mediaInfo.remoteURL = [NSURL URLWithString:JSON[@"url"]];
            mediaInfo.filename = JSON[@"filename"];
            mediaInfo.filesize = @(data.length);
            mediaInfo.key = name;
            mediaInfo.source = self.source;

            success(mediaInfo);
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
                                                     success:success
                                                     failure:failure
                                                    progress:progress];
                    };

                    [self requestAuthenticationFromDelegate];

                    return;
                }
            }
            default:
                break;
        }

        if (failure)
        {
            failure(error);
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

- (void)saveMediaInfo:(FPMediaInfo *)mediaInfo named:(NSString *)name atPath:(NSString *)path success:(FPSimpleAPIUploadSuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure progress:(FPSimpleAPIProgressBlock)progress
{
    FPSimpleAPIUploadSuccessBlock successBlock = ^(FPMediaInfo *uploadedMediaInfo) {
        uploadedMediaInfo.originalAsset = mediaInfo.originalAsset;

        if (success)
        {
            success(uploadedMediaInfo);
        }
    };

    return [self saveMediaAtLocalURL:mediaInfo.mediaURL
                               named:name
                        withMimeType:mediaInfo.MIMEtype
                              atPath:path
                             success:successBlock
                             failure:failure
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

- (void)recursiveGetMediaListAtPath:(NSString *)path partialResults:(NSMutableArray *)partialResults startPage:(NSUInteger)startPage success:(FPSimpleAPIGetMediaListSuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure
{
    [self getMediaListAtPath:path
                   startPage:startPage
                     success: ^(NSArray * __nonnull mediaList, NSUInteger nextPage) {
        [partialResults addObjectsFromArray:mediaList];

        if (nextPage > 0)
        {
            [self recursiveGetMediaListAtPath:path
                               partialResults:partialResults
                                    startPage:nextPage
                                      success:success
                                      failure:failure];
        }
        else
        {
            if (success)
            {
                success([partialResults copy], 0);
            }
        }
    } failure:failure];
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
