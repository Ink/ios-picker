//
//  FPSessionTests.m
//  FPPicker
//
//  Created by Ruben Nine on 14/07/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <XCTest/XCTest.h>

// Collaborators

#import "FPSession.h"

@interface FPSessionTests : XCTestCase

@end

@implementation FPSessionTests

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

- (void)testJSONSessionStringForAPIKeyAndMimetypes
{
    FPSession *session = [FPSession new];

    NSString *emptyJSON = [session JSONSessionString];

    XCTAssertEqualObjects(emptyJSON,
                          @"{\"app\":{}}",
                          @"Should represent an empty session");

    session = [FPSession new];

    session.APIKey = @"MY-API-KEY";

    NSString *JSONWithAPIKey = [session JSONSessionString];

    XCTAssertEqualObjects(JSONWithAPIKey,
                          @"{\"app\":{\"apikey\":\"MY-API-KEY\"}}",
                          @"Should contain an 'apikey' entry");

    session = [FPSession new];

    session.APIKey = @"MY-API-KEY";
    session.mimetypes = @"image/png";

    NSString *JSONWithAPIKeyAndMimetype = [session JSONSessionString];

    XCTAssertEqualObjects(JSONWithAPIKeyAndMimetype,
                          @"{\"app\":{\"apikey\":\"MY-API-KEY\"},\"mimetypes\":\"image\\/png\"}",
                          @"Should contain both an 'apikey' and a 'mimetypes' entry");

    session = [FPSession new];

    session.APIKey = @"MY-API-KEY";
    session.mimetypes = @[@"image/png", @"image/jpeg"];

    NSString *JSONWithAPIKeyAndMimetypes = [session JSONSessionString];

    XCTAssertEqualObjects(JSONWithAPIKeyAndMimetypes,
                          @"{\"app\":{\"apikey\":\"MY-API-KEY\"},\"mimetypes\":[\"image\\/png\",\"image\\/jpeg\"]}",
                          @"Should contain both an 'apikey' and a 'mimetypes' entry");
}

@end
