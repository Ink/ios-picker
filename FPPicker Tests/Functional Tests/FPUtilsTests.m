//
//  FPUtilsTests.m
//  FPPicker
//
//  Created by Ruben Nine on 16/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import <XCTest/XCTest.h>

// Collaborators
#import "FPUtils.h"

// Test support

@interface FPUtilsTests : XCTestCase

@end

@implementation FPUtilsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFrameworkBundle
{
    NSLog(@"bundlePath = %@", [FPUtils frameworkBundle].bundlePath);
    NSLog(@"resourcePath = %@", [NSBundle mainBundle].resourcePath);

    XCTAssertNotNil([FPUtils frameworkBundle].bundlePath,
                    @"Bundle path expected");

    XCTAssertNotEqual([[FPUtils frameworkBundle].bundlePath rangeOfString:@"FPPicker.bundle"].location,
                      NSNotFound,
                      @"FPPicker.bundle is expected in the framework bundle path");
}

@end
