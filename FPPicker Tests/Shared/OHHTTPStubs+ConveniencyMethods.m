//
//  OHHTTPStubs+ConveniencyMethods.m
//  TestedApp
//
//  Created by Ruben Nine on 11/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "OHHTTPStubs+ConveniencyMethods.h"

@implementation OHHTTPStubs (ConveniencyMethods)

+ (void)stubHTTPRequestWithNSURL:(NSURL *)url
                   andHTTPMethod:()HTTPMethod
                        matching:(OHHTTPMatchingMode)matchingOptions
                 withFixtureFile:(NSString *)fixtureFile
                      statusCode:(int)statusCode
                      andHeaders:(NSDictionary *)headers
{
    OHHTTPStubsTestBlock testBlock = ^BOOL (NSURLRequest *request) {
        BOOL shouldStub = NO;

        if (matchingOptions & OHHTTPMatchHost)
        {
            shouldStub = [request.URL.host isEqualToString:url.host];

            if (!shouldStub)
            {
                NSLog(@"(OHHTTPS DEBUG) ✖︎ Host %@ does not match %@", url.host, request.URL.host);

                return NO;
            }
        }

        if (matchingOptions & OHHTTPMatchPath)
        {
            shouldStub = [request.URL.path isEqualToString:url.path];

            if (!shouldStub)
            {
                NSLog(@"(OHHTTPS DEBUG) ✖︎ Path %@ does not match %@", url.path, request.URL.path);

                return NO;
            }
        }

        if (matchingOptions & OHHTTPMatchQueryString)
        {
            shouldStub = !request.URL.query && !url.query; // if both are nil, they are also a match

            if (!shouldStub)
            {
                shouldStub = [request.URL.query isEqualToString:url.query];
            }

            if (!shouldStub)
            {
                NSLog(@"(OHHTTPS DEBUG) ✖︎ Query string %@ does not match %@", url.query, request.URL.query);

                return NO;
            }
        }

        if (matchingOptions & OHHTTPMatchScheme)
        {
            shouldStub = [request.URL.scheme isEqualToString:url.scheme];

            if (!shouldStub)
            {
                NSLog(@"(OHHTTPS DEBUG) ✖︎ Scheme %@ does not match %@", url.scheme, request.URL.scheme);

                return NO;
            }
        }

        return YES;
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
