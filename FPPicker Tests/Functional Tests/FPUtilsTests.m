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
    XCTAssertNotNil([FPUtils frameworkBundle].bundlePath,
                    @"Bundle path expected");

    XCTAssertNotEqual([[FPUtils frameworkBundle].bundlePath rangeOfString:@"FPPicker.bundle"].location,
                      NSNotFound,
                      @"FPPicker.bundle is expected in the framework bundle path");
}

- (void)testUtiForMimetype
{
    XCTAssertEqualObjects([FPUtils utiForMimetype:@"image/jpeg"],
                          @"public.jpeg",
                          @"jpeg UTI should match");

    XCTAssertEqualObjects([FPUtils utiForMimetype:@"image/png"],
                          @"public.png",
                          @"png UTI should match");

    XCTAssertEqualObjects([FPUtils utiForMimetype:@"video/mp4"],
                          @"public.mpeg-4",
                          @"mpeg-4 UTI should match");

    XCTAssertEqualObjects([FPUtils utiForMimetype:@"video/quicktime"],
                          @"com.apple.quicktime-movie",
                          @"quicktime-movie UTI should match");

    XCTAssertEqualObjects([FPUtils utiForMimetype:@"text/plain"],
                          @"public.plain-text",
                          @"plain-text UTI should match");
}

- (void)testUrlEncodeString
{
    NSString *input = @"?name=ståle&car=\"saab\"";
    NSString *expected = @"%3Fname%3Dst%C3%A5le%26car%3D%22saab%22";

    XCTAssertEqualObjects([FPUtils urlEncodeString:input],
                          expected,
                          @"URL encoded string should match");
}

- (void)testMimetypeIsInstanceOfAnotherMimetype
{
    XCTAssertTrue([FPUtils mimetype:@"image/png" instanceOfMimetype:@"image/*"],
                  @"Should be true");

    XCTAssertFalse([FPUtils mimetype:@"image/png" instanceOfMimetype:@"text/*"],
                   @"Should be false");

    XCTAssertTrue([FPUtils mimetype:@"text/plain" instanceOfMimetype:@"text/*"],
                  @"Should be true");

    XCTAssertFalse([FPUtils mimetype:@"text/plain" instanceOfMimetype:@"image/*"],
                   @"Should be false");

    XCTAssertTrue([FPUtils mimetype:@"image/png" instanceOfMimetype:@"*/*"],
                  @"Should be true");

    XCTAssertTrue([FPUtils mimetype:@"text/plain" instanceOfMimetype:@"*/*"],
                  @"Should be true");
}

- (void)testFormatTimeInSeconds
{
    XCTAssertEqualObjects([FPUtils formatTimeInSeconds:10],
                          @"00:10",
                          @"Should match");

    XCTAssertEqualObjects([FPUtils formatTimeInSeconds:211],
                          @"03:31",
                          @"Should match");

    XCTAssertEqualObjects([FPUtils formatTimeInSeconds:3601],
                          @"01:00:01",
                          @"Should match");

    XCTAssertEqualObjects([FPUtils formatTimeInSeconds:3600 * 10 + 1],
                          @"10:00:01",
                          @"Should match");
}

- (void)testGenRandStringLength
{
    XCTAssertNotEqual([FPUtils genRandStringLength:10],
                      [FPUtils genRandStringLength:10],
                      @"Strings should be random");
}

- (void)testJSONEncodeObject
{
    NSDictionary *dic = @{@"alpha":@{@"beta":@"beta-value"}};

    NSError *error;
    NSString *JSONString = [FPUtils JSONEncodeObject:dic
                                               error:&error];

    XCTAssertEqualObjects(JSONString,
                          @"{\"alpha\":{\"beta\":\"beta-value\"}}",
                          @"Should represent a non-empty dictionary");

    NSString *emptyJSONString = [FPUtils JSONEncodeObject:@{}
                                                    error:&error];

    XCTAssertEqualObjects(emptyJSONString,
                          @"{}",
                          @"Should represent an empty dictionary");

    NSString *nilJSONString = [FPUtils JSONEncodeObject:nil
                                                  error:&error];

    XCTAssertNil(nilJSONString,
                 @"Should represent a nil object");
}

- (void)testJSONSessionStringForAPIKeyAndMimetypes
{
    NSString *emptyJSON = [FPUtils JSONSessionStringForAPIKey:nil
                                                 andMimetypes:nil];

    XCTAssertEqualObjects(emptyJSON,
                          @"{\"app\":{}}",
                          @"Should represent an empty session");

    NSString *JSONWithAPIKey = [FPUtils JSONSessionStringForAPIKey:@"MY-API-KEY"
                                                      andMimetypes:nil];

    XCTAssertEqualObjects(JSONWithAPIKey,
                          @"{\"app\":{\"apikey\":\"MY-API-KEY\"}}",
                          @"Should contain an 'apikey' entry");

    NSString *JSONWithAPIKeyAndMimetype = [FPUtils JSONSessionStringForAPIKey:@"MY-API-KEY"
                                                                 andMimetypes:@"image/png"];

    XCTAssertEqualObjects(JSONWithAPIKeyAndMimetype,
                          @"{\"app\":{\"apikey\":\"MY-API-KEY\"},\"mimetypes\":\"image\\/png\"}",
                          @"Should contain both an 'apikey' and a 'mimetypes' entry");

    NSString *JSONWithAPIKeyAndMimetypes = [FPUtils JSONSessionStringForAPIKey:@"MY-API-KEY"
                                                                  andMimetypes:@[@"image/png", @"image/jpeg"]];

    XCTAssertEqualObjects(JSONWithAPIKeyAndMimetypes,
                          @"{\"app\":{\"apikey\":\"MY-API-KEY\"},\"mimetypes\":[\"image\\/png\",\"image\\/jpeg\"]}",
                          @"Should contain both an 'apikey' and a 'mimetypes' entry");
}

@end
