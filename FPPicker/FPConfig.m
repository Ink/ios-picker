//
//  FPConfig.m
//  FPPicker
//
//  Created by Ruben Nine on 12/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
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

- (NSString *)APIKey
{
    if (!_APIKey)
    {
        _APIKey = self.infoDict[@"Filepicker API Key"];
    }

    return _APIKey;
}

- (NSString *)appSecretKey
{
    if (!_appSecretKey)
    {
        _appSecretKey = self.infoDict[@"Filepicker App Secret Key"];
    }

    return _appSecretKey;
}

- (NSString *)storeAccess
{
    if (!_storeAccess)
    {
        _storeAccess = self.infoDict[@"Filepicker Store Access"];
    }

    return _storeAccess;
}

- (NSString *)storeLocation
{
    if (!_storeLocation)
    {
        _storeLocation = self.infoDict[@"Filepicker Store Location"];
    }

    return _storeLocation;
}

- (NSString *)storePath
{
    if (!_storePath)
    {
        _storePath = self.infoDict[@"Filepicker Store Path"];
    }

    return _storePath;
}

- (NSString *)storeContainer
{
    if (!_storeContainer)
    {
        _storeContainer = self.infoDict[@"Filepicker Store Container"];
    }

    return _storeContainer;
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
