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
    NSString *sanitizedPath = [self sanitizeRelativePath:path];
    NSString *loadPath = [self.source.rootPath stringByAppendingString:sanitizedPath];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:loadPath];

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

        success(responseObject[@"contents"], nextPageNumber);
    };

    AFRequestOperationFailureBlock failureOperationBlock = ^(AFHTTPRequestOperation *operation,
                                                             NSError *error) {
        failure(error);
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
        success(mediaInfo);
    };

    FPFetchObjectFailureBlock failureBlock = ^(NSError *error) {
        failure(error);
    };

    FPFetchObjectProgressBlock progressBlock = ^(float value) {
        progress(value);
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

- (void)saveMediaAtLocalURL:(NSURL *)localURL named:(NSString *)name withMimeType:(NSString *)mimetype atPath:(NSString *)path success:(FPSimpleAPISuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure progress:(FPSimpleAPIProgressBlock)progress
{
    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        success();
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        failure(error);
    };

    FPUploadAssetProgressBlock progressBlock = ^(float value) {
        progress(value);
    };

    NSString *sanitizedPath = [self sanitizeRelativePath:path];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@/", self.source.rootPath, sanitizedPath];

    [FPLibrary uploadDataURL:localURL
                       named:name
                      toPath:fullPath
                  ofMimetype:mimetype
         usingOperationQueue:self.operationQueue
                     success:successBlock
                     failure:failureBlock
                    progress:progressBlock];
}

- (void)saveMediaRepresentedByData:(NSData *)data named:(NSString *)name withMimeType:(NSString *)mimetype atPath:(NSString *)path success:(FPSimpleAPISuccessBlock)success failure:(FPSimpleAPIFailureBlock)failure progress:(FPSimpleAPIProgressBlock)progress
{
    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        success();
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        failure(error);
    };

    FPUploadAssetProgressBlock progressBlock = ^(float value) {
        progress(value);
    };

    NSString *sanitizedPath = [self sanitizeRelativePath:path];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@/", self.source.rootPath, sanitizedPath];

    [FPLibrary uploadData:data
                    named:name
                   toPath:fullPath
               ofMimetype:mimetype
      usingOperationQueue:self.operationQueue
                  success:successBlock
                  failure:failureBlock
                 progress:progressBlock];
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
            success([partialResults copy], 0);
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

- (NSString *)sanitizeRelativePath:(NSString *)relativePath
{
    NSString *tmpPath = [relativePath copy];

    if ([tmpPath characterAtIndex:0] == 47) // remove trailing slash, if present
    {
        tmpPath = [tmpPath substringFromIndex:1];
    }

    if (tmpPath.length > 0 &&
        [tmpPath characterAtIndex:tmpPath.length - 1] == 47) // remove leading slash, if present
    {
        tmpPath = [tmpPath substringToIndex:tmpPath.length - 1];
    }

    NSString *sanitizedRelativePath = tmpPath;

    return sanitizedRelativePath;
}

@end
