//
//  FPAPIClient.h
//  FPPicker
//
//  Created by Ruben Nine on 18/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface FPAPIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
             usingOperationQueue:(NSOperationQueue *)operationQueue
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
       constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
             usingOperationQueue:(NSOperationQueue *)operationQueue
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
