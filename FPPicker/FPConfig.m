//
//  FPConfig.m
//  FPPicker
//
//  Created by Ruben Nine on 12/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPConfig.h"
#import "FPUtils.h"

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

- (NSString *)APIKey
{
    if (!_APIKey)
    {
        if ((_APIKey = [self APIKeyContentsFromFile]))
        {
            NSLog(@"(DEBUG) Loaded API KEY from contents of %@ (Info.plist API KEY will be ignored!)", _APIKey);
        }

        if (!_APIKey)
        {
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];

            _APIKey = infoDict[@"Filepicker API Key"];
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

#pragma mark - Only to be used in tests

+ (void)destroyAndRecreateSingleton
{
    FPSharedInstance = [[super allocWithZone:NULL] init];
}

@end
