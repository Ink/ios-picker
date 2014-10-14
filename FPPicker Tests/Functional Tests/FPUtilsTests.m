//
//  FPUtilsTests.m
//  FPPicker
//
//  Created by Ruben Nine on 16/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
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
    XCTAssertEqualObjects([FPUtils UTIForMimetype:@"image/jpeg"],
                          @"public.jpeg",
                          @"jpeg UTI should match");

    XCTAssertEqualObjects([FPUtils UTIForMimetype:@"image/png"],
                          @"public.png",
                          @"png UTI should match");

    XCTAssertEqualObjects([FPUtils UTIForMimetype:@"video/mp4"],
                          @"public.mpeg-4",
                          @"mpeg-4 UTI should match");

    XCTAssertEqualObjects([FPUtils UTIForMimetype:@"video/quicktime"],
                          @"com.apple.quicktime-movie",
                          @"quicktime-movie UTI should match");

    XCTAssertEqualObjects([FPUtils UTIForMimetype:@"text/plain"],
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
    NSDictionary *dic = @{ @"alpha":@{ @"beta":@"beta-value" }};

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

- (void)testFilePickerLocationWithOptionalSecurityForWithEnabledSecurity
{
    NSString *inputFileLocation = @"http://www.local-fp.com/api/file/0tb5XFvXQSzxWaTdCgIA";

    id configMock = OCMPartialMock([FPConfig sharedInstance]);

    OCMStub([configMock appSecretKey]).andReturn(@"MY_OTHER_SECRET_APP_KEY");

    NSString *outputFileLocation = [FPUtils filePickerLocationWithOptionalSecurityFor:inputFileLocation];

    XCTAssert([outputFileLocation hasPrefix:inputFileLocation],
              @"input should be contained in output");

    XCTAssertNotEqual([outputFileLocation rangeOfString:@"policy="].location,
                      NSNotFound,
                      @"policy should be a parameter");

    XCTAssertNotEqual([outputFileLocation rangeOfString:@"signature="].location,
                      NSNotFound,
                      @"signature should be a parameter");
}

- (void)testFilePickerLocationWithOptionalSecurityForWithDisabledSecurity
{
    NSString *inputFileLocation = @"http://www.local-fp.com/api/file/0tb5XFvXQSzxWaTdCgIA";

    id configMock = OCMPartialMock([FPConfig sharedInstance]);

    OCMStub([configMock appSecretKey]).andReturn(nil);

    NSString *outputFileLocation = [FPUtils filePickerLocationWithOptionalSecurityFor:inputFileLocation];

    XCTAssertEqualObjects(outputFileLocation,
                          inputFileLocation,
                          @"output should exactly match input");
}

- (void)testValidateURLAgainstURLPattern
{
    NSString *URLPattern = @"https://app.box.com/api/";
    NSString *givenURL;
    BOOL result;

    givenURL = @"https://app.box.com/api/";

    result = [FPUtils validateURL:givenURL
                againstURLPattern:URLPattern];

    XCTAssertTrue(result, @"Should be valid");

    givenURL = @"https://not-app.box.com/api/";

    result = [FPUtils validateURL:givenURL
                againstURLPattern:URLPattern];

    XCTAssertFalse(result, @"Should be invalid");

    givenURL = @"NOTGOODhttps://app.box.com/api/";

    result = [FPUtils validateURL:givenURL
                againstURLPattern:URLPattern];

    XCTAssertFalse(result, @"Should be invalid");
}

- (void)testValidateURLAgainstURLPatternWithMismatchingSlashes
{
    NSString *URLPattern;
    NSString *givenURL;
    BOOL result;

    URLPattern  = @"https://app.box.com/api";
    givenURL = @"https://app.box.com/api/";

    result = [FPUtils validateURL:givenURL
                againstURLPattern:URLPattern];

    XCTAssertTrue(result, @"Should be valid");

    URLPattern  = @"https://app.box.com/api/";
    givenURL = @"https://app.box.com/api";

    result = [FPUtils validateURL:givenURL
                againstURLPattern:URLPattern];

    XCTAssertTrue(result, @"Should be valid");
}

- (void)testValidateURLAgainstURLPatternWithWildcards
{
    NSString *URLPattern = @"https://*.app.box.com/api/";
    NSString *givenURL;
    BOOL result;

    givenURL = @"https://CUSTOMER_A_APP_NAME.app.box.com/api/";

    result = [FPUtils validateURL:givenURL
                againstURLPattern:URLPattern];

    XCTAssertTrue(result, @"Should be valid");

    givenURL = @"https://CUSTOMER_B_APP_NAME.app.box.com/api/";

    result = [FPUtils validateURL:givenURL
                againstURLPattern:URLPattern];

    XCTAssertTrue(result, @"Should be valid");

    givenURL = @"https://CUSTOMER-C-APP-NAME.app.box.com/api/";

    result = [FPUtils validateURL:givenURL
                againstURLPattern:URLPattern];

    XCTAssertTrue(result, @"Should be valid");

    givenURL = @"https://CUSTOMER-D-APP-NAME_MIX_AND-MATCH-101.app.box.com/api/";

    result = [FPUtils validateURL:givenURL
                againstURLPattern:URLPattern];

    XCTAssertTrue(result, @"Should be valid");

    givenURL = @"https:/CUSTOMER-E-APP-NAME.app.box.com/api/client/auth/open?m=*/*&key=SOME_KEY_HERE&id=0&modal=false";

    result = [FPUtils validateURL:givenURL
                againstURLPattern:URLPattern];

    XCTAssertTrue(result, @"Should be valid");

    givenURL = @"https://app.box.com/api/";

    result = [FPUtils validateURL:givenURL
                againstURLPattern:URLPattern];

    XCTAssertFalse(result, @"Should be invalid");

    givenURL = @"https://SOME.INVALID.URL.app.box.com/api/";

    result = [FPUtils validateURL:givenURL
                againstURLPattern:URLPattern];

    XCTAssertFalse(result, @"Should be invalid");

    givenURL = @"http://INVALID-PROTOCOL.app.box.com/api/";

    result = [FPUtils validateURL:givenURL
                againstURLPattern:URLPattern];

    XCTAssertFalse(result, @"Should be invalid");
}

@end
