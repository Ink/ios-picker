//
//  FPLibraryTests.m
//  FPPicker
//
//  Created by Ruben Nine on 17/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <XCTest/XCTest.h>

// Collaborators

#import "FPPrivateConfig.h"
#import "FPLibrary.h"
#import "FPAPIClient.h"
#import "FPUtils.h"
#import "FPSession.h"


@interface FPLibraryTests : XCTestCase

@end

@interface FPLibrary (PrivateMethods)

+ (void)singlepartUploadData:(NSData*)filedata
                       named:(NSString*)filename
                  ofMimetype:(NSString*)mimetype
                     success:(FPUploadAssetSuccessBlock)success
                     failure:(FPUploadAssetFailureBlock)failure
                    progress:(FPUploadAssetProgressBlock)progress;

+ (void)multipartUploadData:(NSData*)filedata
                      named:(NSString*)filename
                 ofMimetype:(NSString*)mimetype
                    success:(FPUploadAssetSuccessBlock)success
                    failure:(FPUploadAssetFailureBlock)failure
                   progress:(FPUploadAssetProgressBlock)progress;

+ (void)uploadDataToFilepicker:(NSURL*)fileURL
                         named:(NSString*)filename
                    ofMimetype:(NSString*)mimetype
                  shouldUpload:(BOOL)shouldUpload
                       success:(FPUploadAssetSuccessBlock)success
                       failure:(FPUploadAssetFailureBlock)failure
                      progress:(FPUploadAssetProgressBlock)progress;

+ (NSData *)dataSliceWithData:(NSData *)data
                   sliceIndex:(NSUInteger)index;

@end

@implementation FPLibraryTests

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

- (void)testUploadDataToFilePickerWithShouldUploadSetToFalse
{
    dispatch_semaphore_t waitSemaphore = dispatch_semaphore_create(0);

    FPUploadAssetSuccessBlock successBlock;
    FPUploadAssetFailureBlock failureBlock;

    successBlock = ^(id JSON) {
        XCTFail(@"Should not succeed");
    };

    failureBlock = ^(NSError *error, id JSON) {
        XCTAssertTrue(error, @"An error was expected");

        dispatch_semaphore_signal(waitSemaphore);
    };

    [FPLibrary uploadDataToFilepicker:nil
                                named:nil
                           ofMimetype:nil
                         shouldUpload:NO
                              success:successBlock
                              failure:failureBlock
                             progress:nil];

    // Wait for our block to return

    while (dispatch_semaphore_wait(waitSemaphore, DISPATCH_TIME_NOW))
    {
        runTheRunLoopOnce();
    }
}

- (void)testUploadDataToFilePickerWithSmallFile
{
    id FPLibraryMock = OCMClassMock([FPLibrary class]);

    OCMExpect(ClassMethod([FPLibraryMock singlepartUploadData:[OCMArg any]
                                                        named:[OCMArg any]
                                                   ofMimetype:[OCMArg any]
                                                      success:[OCMArg any]
                                                      failure:[OCMArg any]
                                                     progress:[OCMArg any]]));

    size_t smallImageSize = fpMaxChunkSize - 1;
    char *smallImageBuffer = malloc(smallImageSize);
    NSData *smallImage = [NSData dataWithBytesNoCopy:smallImageBuffer
                                              length:smallImageSize
                                        freeWhenDone:YES];

    id NSDataMock = OCMClassMock([NSData class]);

    OCMStub([NSDataMock dataWithContentsOfURL:[OCMArg any]]).andReturn(smallImage);

    [FPLibrary uploadDataToFilepicker:[NSURL URLWithString:@""]
                                named:@"chunkyImage.png"
                           ofMimetype:@"image/png"
                         shouldUpload:YES
                              success:nil
                              failure:nil
                             progress:nil];

    OCMVerifyAll(FPLibraryMock);
    OCMVerifyAll(NSDataMock);
}

- (void)testUploadDataToFilePickerWithLargeFile
{
    id FPLibraryMock = OCMClassMock([FPLibrary class]);

    OCMExpect(ClassMethod([FPLibraryMock multipartUploadData:[OCMArg any]
                                                       named:[OCMArg any]
                                                  ofMimetype:[OCMArg any]
                                                     success:[OCMArg any]
                                                     failure:[OCMArg any]
                                                    progress:[OCMArg any]]));

    size_t largeImageSize = fpMaxChunkSize + 1;
    char *largeImageBuffer = malloc(largeImageSize);
    NSData *largeImage = [NSData dataWithBytesNoCopy:largeImageBuffer
                                              length:largeImageSize
                                        freeWhenDone:YES];

    id NSDataMock = OCMClassMock([NSData class]);

    OCMStub([NSDataMock dataWithContentsOfURL:[OCMArg any]]).andReturn(largeImage);

    [FPLibrary uploadDataToFilepicker:[NSURL URLWithString:@""]
                                named:@"chunkyImage.png"
                           ofMimetype:@"image/png"
                         shouldUpload:YES
                              success:nil
                              failure:nil
                             progress:nil];

    OCMVerifyAll(FPLibraryMock);
    OCMVerifyAll(NSDataMock);
}

- (void)testSuccessfulSinglepartUpload
{
    dispatch_semaphore_t waitSemaphore = dispatch_semaphore_create(0);
    id configMock = OCMPartialMock([FPConfig sharedInstance]);

    OCMStub([configMock APIKeyContentsFromFile]).andReturn(@"MY_FAKE_API_KEY");

    NSString *imageFilename = @"outline.png";
    NSString *imageMimetype = @"image/png";
    NSString *imageFixtureFilepath = OHPathForFileInBundle(imageFilename, nil);
    NSData *data = [NSData dataWithContentsOfFile:imageFixtureFilepath];

    XCTAssertTrue(data.length > 0, @"Fixture data expected");

    NSURL *expectedURL = [NSURL URLWithString:@"/api/path/computer"
                                relativeToURL:[FPConfig sharedInstance].baseURL];

    [OHHTTPStubs stubHTTPRequestWithNSURL:expectedURL
                            andHTTPMethod:@"POST"
                                 matching:OHHTTPMatchAll
                          withFixtureFile:@"successfulResponse.json"
                               statusCode:200
                               andHeaders:@{@"Content-Type":@"text/json"}];

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        dispatch_semaphore_signal(waitSemaphore);
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        XCTFail(@"Should not fail");
    };

    [FPLibrary singlepartUploadData:data
                              named:imageFilename
                         ofMimetype:imageMimetype
                            success:successBlock
                            failure:failureBlock
                           progress:nil];

    // Wait for our block to return

    while (dispatch_semaphore_wait(waitSemaphore, DISPATCH_TIME_NOW))
    {
        runTheRunLoopOnce();
    }

    OCMVerifyAll(configMock);
}

- (void)testFailingSinglepartUpload
{
    dispatch_semaphore_t waitSemaphore = dispatch_semaphore_create(0);
    id configMock = OCMPartialMock([FPConfig sharedInstance]);

    OCMStub([configMock APIKeyContentsFromFile]).andReturn(@"MY_FAKE_API_KEY");

    NSString *imageFilename = @"outline.png";
    NSString *imageMimetype = @"image/png";
    NSString *imageFixtureFilepath = OHPathForFileInBundle(imageFilename, nil);
    NSData *data = [NSData dataWithContentsOfFile:imageFixtureFilepath];

    XCTAssertTrue(data.length > 0, @"Fixture data expected");

    NSURL *expectedURL = [NSURL URLWithString:@"/api/path/computer"
                                relativeToURL:[FPConfig sharedInstance].baseURL];

    [OHHTTPStubs stubHTTPRequestWithNSURL:expectedURL
                            andHTTPMethod:@"POST"
                                 matching:OHHTTPMatchAll
                          withFixtureFile:@"failureResponse.json"
                               statusCode:200
                               andHeaders:@{@"Content-Type":@"text/json"}];

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        XCTFail(@"Should not succeed");
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        dispatch_semaphore_signal(waitSemaphore);
    };

    [FPLibrary singlepartUploadData:data
                              named:imageFilename
                         ofMimetype:imageMimetype
                            success:successBlock
                            failure:failureBlock
                           progress:nil];

    // Wait for our block to return

    while (dispatch_semaphore_wait(waitSemaphore, DISPATCH_TIME_NOW))
    {
        runTheRunLoopOnce();
    }

    OCMVerifyAll(configMock);
}

- (void)testSuccessfulMultipartUpload
{
    /**
        This test ensures a multipart upload is performed following this sequence:

        1. POST to /api/path/computer?multipart=start
        2. For each chunk { POST to /api/path/computer/?multipart=upload&... }
        3. POST to /api/path/computer?multipart=end

        In this test, our upload will contain 2 chunks of: fpMaxChunkSize and 1 byte respectively.
     */

    dispatch_semaphore_t waitSemaphore = dispatch_semaphore_create(0);
    id configMock = OCMPartialMock([FPConfig sharedInstance]);

    OCMStub([configMock APIKeyContentsFromFile]).andReturn(@"MY_FAKE_API_KEY");

    NSString *imageFilename = @"outline.png";
    NSString *imageMimetype = @"image/png";

    size_t totalSize = fpMaxChunkSize + 1;
    char *bytes = malloc(totalSize);

    NSData *data = [NSData dataWithBytesNoCopy:bytes
                                        length:totalSize
                                  freeWhenDone:YES];

    NSURL *expectedStartURL = [NSURL URLWithString:@"/api/path/computer?multipart=start"
                                     relativeToURL:[FPConfig sharedInstance].baseURL];

    [OHHTTPStubs stubHTTPRequestWithNSURL:expectedStartURL
                            andHTTPMethod:@"POST"
                                 matching:OHHTTPMatchAll
                          withFixtureFile:@"successfulMultipartStartResponse.json"
                               statusCode:200
                               andHeaders:@{@"Content-Type":@"text/json"}];

    FPSession *session = [FPSession new];

    session.APIKey = @"MY-API-KEY";

    NSString *escapedSessionString = [FPUtils urlEncodeString:[session JSONSessionString]];


    NSString *firstChunkPath = [NSString stringWithFormat:@"/api/path/computer/?multipart=upload&id=BQOwM2NHSFOsNKM3STwG&index=0&js_session=%@",
                                escapedSessionString];

    NSURL *expectedFirstChunkURL = [NSURL URLWithString:firstChunkPath
                                          relativeToURL:[FPConfig sharedInstance].baseURL];

    [OHHTTPStubs stubHTTPRequestWithNSURL:expectedFirstChunkURL
                            andHTTPMethod:@"POST"
                                 matching:OHHTTPMatchAll
                          withFixtureFile:@"successfulMultipartUploadResponse.json"
                               statusCode:200
                               andHeaders:@{@"Content-Type":@"text/json"}];


    NSString *secondChunkPath = [NSString stringWithFormat:@"/api/path/computer/?multipart=upload&id=BQOwM2NHSFOsNKM3STwG&index=1&js_session=%@",
                                 escapedSessionString];

    NSURL *expectedSecondChunkURL = [NSURL URLWithString:secondChunkPath
                                           relativeToURL:[FPConfig sharedInstance].baseURL];

    [OHHTTPStubs stubHTTPRequestWithNSURL:expectedSecondChunkURL
                            andHTTPMethod:@"POST"
                                 matching:OHHTTPMatchAll
                          withFixtureFile:@"successfulMultipartUploadResponse.json"
                               statusCode:200
                               andHeaders:@{@"Content-Type":@"text/json"}];

    NSURL *expectedEndURL = [NSURL URLWithString:@"/api/path/computer?multipart=end"
                                   relativeToURL:[FPConfig sharedInstance].baseURL];

    [OHHTTPStubs stubHTTPRequestWithNSURL:expectedEndURL
                            andHTTPMethod:@"POST"
                                 matching:OHHTTPMatchAll
                          withFixtureFile:@"successfulMultipartEndResponse.json"
                               statusCode:200
                               andHeaders:@{@"Content-Type":@"text/json"}];

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        dispatch_semaphore_signal(waitSemaphore);
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        XCTFail(@"Should not fail");
    };

    [FPLibrary multipartUploadData:data
                             named:imageFilename
                        ofMimetype:imageMimetype
                           success:successBlock
                           failure:failureBlock
                          progress:nil];

    // Wait for our block to return

    while (dispatch_semaphore_wait(waitSemaphore, DISPATCH_TIME_NOW))
    {
        runTheRunLoopOnce();
    }

    OCMVerifyAll(configMock);
}

- (void)testFailingMultipartUpload
{
    // TODO: Implement
}

- (void)testDataSliceWithSmallData
{
    size_t totalSize = 32;
    char *bytes = malloc(totalSize);

    NSData *data = [NSData dataWithBytesNoCopy:bytes
                                        length:totalSize
                                  freeWhenDone:YES];

    NSData *dataSlice;

    dataSlice = [FPLibrary dataSliceWithData:data
                                  sliceIndex:0];

    XCTAssertEqual(data.length, dataSlice.length, @"Lengths should be equal");
    XCTAssertEqualObjects(data, dataSlice, @"Data should be fully contained in dataSlice");
}

- (void)testDataSliceWithLargeData
{
    NSData *dataSlice;
    NSRange subdataRange;

    size_t totalSize = (fpMaxChunkSize * 2) - 1;
    char *bytes = malloc(totalSize);

    NSData *data = [NSData dataWithBytesNoCopy:bytes
                                        length:totalSize
                                  freeWhenDone:YES];

    dataSlice = [FPLibrary dataSliceWithData:data
                                  sliceIndex:0];

    XCTAssertEqual(dataSlice.length,
                   fpMaxChunkSize,
                   @"Length should be equal to fpMaxChunkSize");

    subdataRange = NSMakeRange(0, fpMaxChunkSize);

    XCTAssertTrue([dataSlice isEqualToData:[data subdataWithRange:subdataRange]],
                  @"Should match");

    dataSlice = [FPLibrary dataSliceWithData:data
                                  sliceIndex:1];

    XCTAssertEqual(dataSlice.length, fpMaxChunkSize - 1,
                   @"Length should be equal to fpMaxChunkSize - 1");

    subdataRange = NSMakeRange(fpMaxChunkSize, fpMaxChunkSize - 1);

    XCTAssertTrue([dataSlice isEqualToData:[data subdataWithRange:subdataRange]],
                  @"Should match");
}

- (void)testDataSliceBeyondBounds
{
    NSData *dataSlice;

    size_t totalSize = fpMaxChunkSize;
    char *bytes = malloc(totalSize);

    NSData *data = [NSData dataWithBytesNoCopy:bytes
                                        length:totalSize
                                  freeWhenDone:YES];

    dataSlice = [FPLibrary dataSliceWithData:data
                                  sliceIndex:1];

    XCTAssertNil(dataSlice,
                 @"should be nil");
}

@end
