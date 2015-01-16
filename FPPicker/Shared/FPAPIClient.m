//
//  FPAPIClient.m
//  FPPicker
//
//  Created by Ruben Nine on 18/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPAPIClient.h"
#import "FPConfig.h"

@implementation FPAPIClient

+ (instancetype)sharedClient
{
    static FPAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedClient = [[FPAPIClient alloc] initWithBaseURL:[FPConfig sharedInstance].baseURL];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        _sharedClient.operationQueue.maxConcurrentOperationCount = 5;
    });

    return _sharedClient;
}

-(AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                   success:(void (^)(AFHTTPRequestOperation *, id))success
                                                   failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    //AFHTTPRequestSerializer adds User-Agent header to request
    NSURLRequest *serialzedRequest = [[AFHTTPRequestSerializer serializer] requestBySerializingRequest:request withParameters:nil error:nil];
    
    return [super HTTPRequestOperationWithRequest:serialzedRequest success:success failure:failure];
}

@end
