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
            NSString *theAPIKey = [NSString stringWithContentsOfFile:envAPIKey
                                                            encoding:NSUTF8StringEncoding
                                                               error:nil];

            _APIKey = [theAPIKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            if (_APIKey)
            {
                NSLog(@"(DEBUG) Loaded API KEY from contents of %@ (Info.plist API KEY will be ignored!)", envAPIKey);
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
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    return [cookieStorage cookiesForURL:self.baseURL];
}

@end
