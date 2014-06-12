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
        NSString *envAPIKey = [[NSProcessInfo processInfo] environment][@"API_KEY_FILE"];

        if (envAPIKey)
        {
            NSLog(@"(DEBUG) Loading API KEY from contents of %@ (Info.plist API KEY will be ignored!)", envAPIKey);

            _APIKey = [NSString stringWithContentsOfFile:envAPIKey
                                                encoding:NSUTF8StringEncoding
                                                   error:nil];

            if (!_APIKey)
            {
                NSLog(@"ERROR: Unable to load API KEY from contents of %@", envAPIKey);
            }
        }

        if (!_APIKey)
        {
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];

            _APIKey = [infoDict objectForKey:@"Filepicker API Key"];
        }
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
