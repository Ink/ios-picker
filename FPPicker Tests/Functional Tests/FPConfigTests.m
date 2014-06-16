//
//  FPConfigTests.m
//  FPPicker
//
//  Created by Ruben Nine on 16/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestHelpers.h"
#import "NSDictionary+FPMerge.h"

// Collaborators
#import "FPConfig.h"

// Test support
#import "OCMock.h"
#import "OCClassMockObject.h"

@interface FPConfigTests : XCTestCase

@end

@interface FPConfig (DestroyableSingleton)

+ (void)destroyAndRecreateSingleton;

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

    NSLog(@"sharedInstance = %@", [FPConfig sharedInstance]);
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

- (void)testAPIKeyFromFile
{
    FPConfig *config = [FPConfig sharedInstance];
    id configMock = OCMPartialMock(config);

    OCMStub([configMock APIKeyContentsFromFile]).andReturn(@"MY_API_KEY");

    XCTAssertEqualObjects(config.APIKey,
                          @"MY_API_KEY",
                          @"API key does not match");

    OCMVerifyAll(configMock);
}

- (void)testAPIKeyFromPList
{
    FPConfig *config = [FPConfig sharedInstance];
    id configMock = OCMPartialMock(config);

    OCMStub([configMock APIKeyContentsFromFile]); // return nil

    id mainBundleMock = OCMPartialMock([NSBundle mainBundle]);

    NSDictionary *infoDictionary = [NSDictionary mergeDictionary:[[NSBundle mainBundle] infoDictionary]
                                                            into:@{@"Filepicker API Key":@"MY_OTHER_API_KEY"}];

    OCMStub([mainBundleMock infoDictionary]).andReturn(infoDictionary);

    XCTAssertEqualObjects(config.APIKey,
                          @"MY_OTHER_API_KEY",
                          @"API key does not match");

    OCMVerifyAll(configMock);
}

@end
