//
//  OHHTTPStubs+ConveniencyMethods.h
//  TestedApp
//
//  Created by Ruben Nine on 11/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "OHHTTPStubs.h"

typedef enum : NSUInteger
{
    OHHTTPMatchHost = (1 << 0),
    OHHTTPMatchPath = (1 << 1),
    OHHTTPMatchQueryString = (1 << 2),
    OHHTTPMatchScheme = (1 << 3),
    OHHTTPMatchAll = OHHTTPMatchHost | OHHTTPMatchPath | OHHTTPMatchScheme | OHHTTPMatchQueryString
} OHHTTPMatchingMode;

@interface OHHTTPStubs (ConveniencyMethods)

+ (void)stubHTTPRequestWithNSURL:(NSURL *)url
                   andHTTPMethod:()HTTPMethod
                        matching:(OHHTTPMatchingMode)matchingOptions
                 withFixtureFile:(NSString *)fixtureFile
                      statusCode:(int)statusCode
                      andHeaders:(NSDictionary *)headers;

@end
