//
//  FPConfig.m
//  FPPicker
//
//  Created by Ruben Nine on 12/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPConfig.h"

@implementation FPConfig

+ (instancetype)sharedInstance
{
    static FPConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [FPConfig new];
    });

    return sharedInstance;
}

- (NSString *)APIKey
{
    if (!_APIKey)
    {
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];

        _APIKey = [infoDict objectForKey:@"Filepicker API Key"];
    }

    return _APIKey;
}

- (NSURL *)baseURL
{
    if (!_baseURL)
    {
        _baseURL = [NSURL URLWithString:fpBASE_URL];
    }

    return _baseURL;
}

- (NSArray *)cookies
{
    if (!_cookies)
    {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

        _cookies = [cookieStorage cookiesForURL:self.baseURL];
    }

    return _cookies;
}

@end