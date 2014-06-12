//
//  OHHTTPStubs+ConveniencyMethods.m
//  TestedApp
//
//  Created by Ruben Nine on 11/06/14.
//  Copyright (c) 2014 Filepicker.io (Cloudtop Inc.). All rights reserved.
//

#import "OHHTTPStubs+ConveniencyMethods.h"

static inline NSString *boolAsString(BOOL value)
{
    return value ? @"YES" : @"NO";
}

@implementation OHHTTPStubs (ConveniencyMethods)

+ (void)stubHTTPRequestAndResponseWithHost:(NSString *)host
                                      path:(NSString *)path
                                    scheme:(NSString *)scheme
                               fixtureFile:(NSString *)fixtureFile
                                statusCode:(int)statusCode
                                andHeaders:(NSDictionary *)headers
{
    OHHTTPStubsTestBlock testBlock = ^BOOL (NSURLRequest *request) {
        BOOL shouldStub = [request.URL.scheme isEqualToString:scheme] &&
                          [request.URL.host isEqualToString:host] &&
                          [request.URL.path isEqualToString:path];

        NSLog(@"(OHHTTPS DEBUG) host = %@, path = %@, willStub = %@", host, path, boolAsString(shouldStub));

        return shouldStub;
    };

    OHHTTPStubsResponseBlock responseBlock = ^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSString *fixture = OHPathForFileInBundle(fixtureFile, nil);

        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:statusCode
                                                   headers:headers];
    };


    [OHHTTPStubs stubRequestsPassingTest:testBlock
                        withStubResponse:responseBlock];
}

@end
