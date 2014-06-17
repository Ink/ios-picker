//
//  FPSourceTests.m
//  FPPicker
//
//  Created by Ruben Nine on 16/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import <XCTest/XCTest.h>

// Collaborators
#import "FPSource.h"

@interface FPSourceTests : XCTestCase

@end

@implementation FPSourceTests

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

- (void)testMimetypeString
{
    FPSource *source = [FPSource new];

    XCTAssertEqual(source.mimetypes.count,
                   0,
                   @"Should be zero");

    XCTAssertEqualObjects([source mimetypeString],
                          @"[]",
                          @"Should be empty");

    source.mimetypes = @[
        @"image/png",
        @"image/jpeg",
        @"video/mp4",
        @"video/quicktime"
                       ];

    XCTAssertEqual(source.mimetypes.count,
                   4,
                   @"Should be 4");

    XCTAssertEqualObjects([source mimetypeString],
                          @"[\"image/png\",\"image/jpeg\",\"video/mp4\",\"video/quicktime\"]",
                          @"Should contain mimetypes");
}

@end
