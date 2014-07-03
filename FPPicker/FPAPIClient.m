//
//  FPAPIClient.m
//  FPPicker
//
//  Created by Ruben Nine on 18/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
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

@end
