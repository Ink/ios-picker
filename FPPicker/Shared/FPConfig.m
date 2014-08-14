//
//  FPConfig.m
//  FPPicker
//
//  Created by Ruben Nine on 12/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPConfig.h"
#import "FPPrivateConfig.h"

@interface FPConfig ()

@property (nonatomic, readwrite, strong) NSURL *baseURL;

@end

@implementation FPConfig

static FPConfig *FPSharedInstance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        FPSharedInstance = [[super allocWithZone:NULL] init];
    });

    return FPSharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

#pragma mark - Accessors

- (NSURL *)baseURL
{
    if (!_baseURL)
    {
        _baseURL = [NSURL URLWithString:fpBASE_URL];
    }

    return _baseURL;
}

#pragma mark - Private

- (NSArray *)cookies
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    return [cookieStorage cookiesForURL:self.baseURL];
}

- (NSDictionary *)infoDict
{
    return [NSBundle mainBundle].infoDictionary;
}

#pragma mark - Only to be used in tests

+ (void)destroyAndRecreateSingleton
{
    FPSharedInstance = [[super allocWithZone:NULL] init];
}

@end
