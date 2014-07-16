//
//  FPConfig.m
//  FPPicker
//
//  Created by Ruben Nine on 12/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPConfig.h"

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

#pragma mark - Public Methods

- (NSString *)APIKeyContentsFromFile
{
    NSString *envAPIKey = [[NSProcessInfo processInfo] environment][@"API_KEY_FILE"];

    NSString *theAPIKey = [NSString stringWithContentsOfFile:envAPIKey
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];

    // Trim whitespace and new lines

    theAPIKey = [theAPIKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    return theAPIKey;
}

- (NSArray *)cookies
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    return [cookieStorage cookiesForURL:self.baseURL];
}

#pragma mark - Accessors

- (NSString *)APIKey
{
    if (!_APIKey)
    {
        if ((_APIKey = [self APIKeyContentsFromFile]))
        {
            NSLog(@"(DEBUG) Reading API KEY from API_KEY file (Info.plist entry will be ignored)");
        }

        if (!_APIKey)
        {
            _APIKey = self.infoDict[@"Filepicker API Key"];
        }
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

- (NSURL *)baseURL
{
    if (!_baseURL)
    {
        _baseURL = [NSURL URLWithString:fpBASE_URL];
    }

    return _baseURL;
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
