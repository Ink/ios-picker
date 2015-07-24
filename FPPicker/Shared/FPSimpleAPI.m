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

@property (nonatomic, strong) FPSource *source;

/*!
   The operation queue to use for any requests to the REST API.
 */
@property (nonatomic, strong) NSOperationQueue *operationQueue;

/*!
    Post authentication block.
 */
@property (nonatomic, strong) FPSimpleAPIPostAuthenticationActionBlock postAuthenticationActionBlock;

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

- (instancetype)initWithSource:(nonnull FPSource *)source
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

- (void)getMediaListAtPath:(nonnull NSString *)path success:(nullable FPSimpleAPIGetMediaListSuccessBlock)success failure:(nullable FPSimpleAPIFailureBlock)failure
{
    [self getMediaListAtPath:path
             withCachePolicy:NSURLRequestReturnCacheDataElseLoad
                     success:success
                     failure:failure];
}

- (void)getMediaListAtPath:(nonnull NSString *)path withCachePolicy:(NSURLRequestCachePolicy)cachePolicy success:(nullable FPSimpleAPIGetMediaListSuccessBlock)success failure:(nullable FPSimpleAPIFailureBlock)failure
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

    [self.operationQueue addOperation:operation];
}

- (void)getMediaInfoAtPath:(nonnull NSString *)path success:(nullable FPSimpleAPIGetMediaSuccessBlock)success failure:(nullable FPSimpleAPIFailureBlock)failure progress:(nullable FPSimpleAPIProgressBlock)progress
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

- (void)saveMediaAtLocalURL:(nonnull NSURL *)localURL named:(nonnull NSString *)name withMimeType:(nonnull NSString *)mimetype atPath:(nonnull NSString *)path success:(nullable FPSimpleAPISuccessBlock)success failure:(nullable FPSimpleAPIFailureBlock)failure progress:(nullable FPSimpleAPIProgressBlock)progress
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

- (void)saveMediaRepresentedByData:(nonnull NSData *)data named:(nonnull NSString *)name withMimeType:(nonnull NSString *)mimetype atPath:(nonnull NSString *)path success:(nullable FPSimpleAPISuccessBlock)success failure:(nullable FPSimpleAPIFailureBlock)failure progress:(nullable FPSimpleAPIProgressBlock)progress
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

    if ([tmpPath characterAtIndex:tmpPath.length - 1] == 47) // remove leading slash, if present
    {
        tmpPath = [tmpPath substringToIndex:tmpPath.length - 1];
    }

    NSString *sanitizedRelativePath = tmpPath;

    return sanitizedRelativePath;
}

@end
