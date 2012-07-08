//
//  FPConfig.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#define fpBASE_URL                  @"https://www.filepicker.io"

#define fpDEVICE_NAME               [[UIDevice currentDevice] name]
#define fpDEVICE_OS                 [[UIDevice currentDevice] systemName]
#define fpDEVICE_VERSION            [[UIDevice currentDevice] systemVersion]
#define fpCOOKIES                   [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:fpBASE_URL]]
#define fpBASE_NSURL                [NSURL URLWithString:fpBASE_URL]


//You can get a filepicker apikey by signing up at www.filepicker.io
#define fpAPIKEY                    [[NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]] mutabilityOption:0 format:NULL errorDescription:NULL] objectForKey:@"Filepicker API Key"]

#define fpWindowSize                CGSizeMake(320, 480)