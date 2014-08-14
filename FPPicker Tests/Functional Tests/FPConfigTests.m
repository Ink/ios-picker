//
//  FPConfigTests.m
//  FPPicker
//
//  Created by Ruben Nine on 16/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <XCTest/XCTest.h>

// Collaborators

#import "FPPrivateConfig.h"

@interface FPConfigTests : XCTestCase

@end

@implementation FPConfigTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];

    [FPConfig destroyAndRecreateSingleton];
}

- (void)testSharedInstance
{
    FPConfig *config1 = [FPConfig sharedInstance];
    FPConfig *config2 = [FPConfig sharedInstance];

    XCTAssertEqualObjects(config1,
                          config2,
                          @"Singleton objects should match");
}

- (void)testNewReturnsTheSharedInstance
{
    FPConfig *config1 = [FPConfig sharedInstance];
    FPConfig *config2 = [FPConfig new];

    XCTAssertEqualObjects(config1,
                          config2,
                          @"new should return a shared instance");
}

- (void)testAPIKeyFromPList
{
    id configMock = OCMPartialMock([FPConfig sharedInstance]);

    OCMStub([configMock APIKeyContentsFromFile]); // return nil

    id mainBundleMock = OCMPartialMock([NSBundle mainBundle]);

    NSDictionary *infoDictionary = [NSDictionary mergeDictionary:[[NSBundle mainBundle] infoDictionary]
                                                            into:@{@"Filepicker API Key":@"MY_OTHER_API_KEY"}];

    OCMStub([mainBundleMock infoDictionary]).andReturn(infoDictionary);

    XCTAssertEqualObjects([FPConfig sharedInstance].APIKey,
                          @"MY_OTHER_API_KEY",
                          @"API key does not match");

    OCMVerifyAll(configMock);
}

- (void)testAPIKeyUsingMacro
{
    id configMock = OCMPartialMock([FPConfig sharedInstance]);

    OCMStub([configMock APIKeyContentsFromFile]).andReturn(@"MY_API_KEY");

    XCTAssertEqualObjects([FPConfig sharedInstance].APIKey,
                          fpAPIKEY,
                          @"fpAPIKEY macro should return the same as config.APIKey");

    OCMVerifyAll(configMock);
}

- (void)testAppSecretKeyFromPList
{
    id configMock = OCMPartialMock([FPConfig sharedInstance]);
    id mainBundleMock = OCMPartialMock([NSBundle mainBundle]);

    NSDictionary *infoDictionary = [NSDictionary mergeDictionary:[[NSBundle mainBundle] infoDictionary]
                                                            into:@{@"Filepicker App Secret Key":@"MY_SECRET_APP_KEY"}];

    OCMStub([mainBundleMock infoDictionary]).andReturn(infoDictionary);

    XCTAssertEqualObjects([FPConfig sharedInstance].appSecretKey,
                          @"MY_SECRET_APP_KEY",
                          @"App secret key does not match");

    OCMVerifyAll(configMock);
}

- (void)testAppSecretKeyUsingMacro
{
    id configMock = OCMPartialMock([FPConfig sharedInstance]);

    OCMStub([configMock appSecretKey]).andReturn(@"MY_OTHER_SECRET_APP_KEY");

    XCTAssertEqualObjects([FPConfig sharedInstance].appSecretKey,
                          fpAPPSECRETKEY,
                          @"fpAPPSECRETKEY macro should return the same as config.appSecretKey");

    OCMVerifyAll(configMock);
}

- (void)testBaseURL
{
    XCTAssertEqualObjects([FPConfig sharedInstance].baseURL.absoluteString,
                          fpBASE_URL,
                          @"BaseURL does not match");
}

- (void)testCookies
{
    NSArray *expectedCookies = @[
        @"someCookie=1"
                               ];

    id cookieStorageMock = OCMPartialMock([NSHTTPCookieStorage sharedHTTPCookieStorage]);

    OCMStub([cookieStorageMock cookiesForURL:[OCMArg any]]).andReturn(expectedCookies);

    XCTAssertEqualObjects([FPConfig sharedInstance].cookies,
                          expectedCookies,
                          @"Cookies do not match");

    OCMVerifyAll(cookieStorageMock);
}

- (void)testCookiesUsingMacro
{
    NSArray *expectedCookies = @[
        @"cookieOne=10",
        @"cookieTwo=20"
                               ];

    id cookieStorageMock = OCMPartialMock([NSHTTPCookieStorage sharedHTTPCookieStorage]);

    OCMStub([cookieStorageMock cookiesForURL:[OCMArg any]]).andReturn(expectedCookies);

    XCTAssertEqualObjects(fpCOOKIES,
                          expectedCookies,
                          @"Cookies do not match");

    OCMVerifyAll(cookieStorageMock);
}

@end
