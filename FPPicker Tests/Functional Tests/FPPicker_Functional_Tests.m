//
//  FPPicker_Functional_Tests.m
//  FPPicker Functional Tests
//
//  Created by Ruben Nine on 12/06/14.
//  Copyright (c) 2014 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestHelpers.h"
#import "OHHTTPStubs+ConveniencyMethods.h"

// Collaborators

// Test support
#import <OHHTTPStubs.h>

@interface FPPicker_Functional_Tests : XCTestCase
@end

@implementation FPPicker_Functional_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];

    [OHHTTPStubs removeAllStubs];
}

#pragma mark - Tests

- (void)testTrue
{
    XCTAssertTrue(TRUE, @"true");
}

@end
