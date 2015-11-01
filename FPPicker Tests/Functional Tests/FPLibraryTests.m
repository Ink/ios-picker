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

+ (void)uploadLocalURLToFilepicker:(NSURL *)localURL
                             named:(NSString *)filename
                        ofMimetype:(NSString *)mimetype
               usingOperationQueue:(NSOperationQueue *)operationQueue
                           success:(FPUploadAssetSuccessBlock)success
                           failure:(FPUploadAssetFailureBlock)failure
                          progress:(FPUploadAssetProgressBlock)progress;

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

        dispatch_semaphore_signal(waitSemaphore);
    };

    failureBlock = ^(NSError *error, id JSON) {
        XCTAssertTrue(error, @"An error was expected");

        dispatch_semaphore_signal(waitSemaphore);
    };

    [FPLibrary uploadLocalURLToFilepicker:nil
                                    named:nil
                               ofMimetype:nil
                      usingOperationQueue:nil
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

    OCMExpect(ClassMethod([FPLibraryMock uploadLocalURLToFilepicker:[OCMArg any]
                                                              named:[OCMArg any]
                                                         ofMimetype:[OCMArg any]
                                                usingOperationQueue:[OCMArg any]
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

    [FPLibrary uploadLocalURLToFilepicker:[NSURL URLWithString:@""]
                                    named:@"chunkyImage.png"
                               ofMimetype:@"image/png"
                      usingOperationQueue:nil
                                  success:nil
                                  failure:nil
                                 progress:nil];

    OCMVerifyAll(FPLibraryMock);
    OCMVerifyAll(NSDataMock);
}

- (void)testUploadDataToFilePickerWithLargeFile
{
    id FPLibraryMock = OCMClassMock([FPLibrary class]);

    OCMExpect(ClassMethod([FPLibraryMock uploadLocalURLToFilepicker:[OCMArg any]
                                                              named:[OCMArg any]
                                                         ofMimetype:[OCMArg any]
                                                usingOperationQueue:[OCMArg any]
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

    [FPLibrary uploadLocalURLToFilepicker:[NSURL URLWithString:@""]
                                    named:@"chunkyImage.png"
                               ofMimetype:@"image/png"
                      usingOperationQueue:nil
                                  success:nil
                                  failure:nil
                                 progress:nil];

    OCMVerifyAll(FPLibraryMock);
    OCMVerifyAll(NSDataMock);
}

// NOTE(2015-11-1): Tests are disabled since FPSinglepartUploader is currently disabled
//- (void)testSuccessfulSinglepartUpload
//{
//    dispatch_semaphore_t waitSemaphore = dispatch_semaphore_create(0);
//    id configMock = OCMPartialMock([FPConfig sharedInstance]);
//
//    OCMStub([configMock APIKey]).andReturn(@"MY_FAKE_API_KEY");
//
//    NSString *imageFilename = @"outline.png";
//    NSString *imageMimetype = @"image/png";
//    NSString *imageFixtureFilepath = OHPathForFileInBundle(imageFilename, nil);
//    NSData *data = [NSData dataWithContentsOfFile:imageFixtureFilepath];
//
//    XCTAssertTrue(data.length > 0, @"Fixture data expected");
//
//    NSURL *expectedURL = [NSURL URLWithString:@"/api/path/computer"
//                                relativeToURL:[FPConfig sharedInstance].baseURL];
//
//    [OHHTTPStubs stubHTTPRequestWithNSURL:expectedURL
//                            andHTTPMethod:@"POST"
//                                 matching:OHHTTPMatchAll
//                          withFixtureFile:@"successfulResponse.json"
//                               statusCode:200
//                               andHeaders:@{@"Content-Type":@"text/json"}];
//
//    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
//        dispatch_semaphore_signal(waitSemaphore);
//    };
//
//    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
//        XCTFail(@"Should not fail");
//    };
//
//    [FPLibrary uploadData:data
//                    named:imageFilename
//                   toPath:imageFilename
//               ofMimetype:imageMimetype
//      usingOperationQueue:nil
//                  success:successBlock
//                  failure:failureBlock
//                 progress:nil];
//
//    // Wait for our block to return
//
//    while (dispatch_semaphore_wait(waitSemaphore, DISPATCH_TIME_NOW))
//    {
//        runTheRunLoopOnce();
//    }
//
//    OCMVerifyAll(configMock);
//}

// NOTE(2015-11-1): Tests are disabled since FPSinglepartUploader is currently disabled
//- (void)testFailingSinglepartUpload
//{
//    dispatch_semaphore_t waitSemaphore = dispatch_semaphore_create(0);
//    id configMock = OCMPartialMock([FPConfig sharedInstance]);
//
//    OCMStub([configMock APIKey]).andReturn(@"MY_FAKE_API_KEY");
//
//    NSString *imageFilename = @"outline.png";
//    NSString *imageMimetype = @"image/png";
//    NSString *imageFixtureFilepath = OHPathForFileInBundle(imageFilename, nil);
//    NSData *data = [NSData dataWithContentsOfFile:imageFixtureFilepath];
//
//    XCTAssertTrue(data.length > 0, @"Fixture data expected");
//
//    NSURL *expectedURL = [NSURL URLWithString:@"/api/path/computer"
//                                relativeToURL:[FPConfig sharedInstance].baseURL];
//
//    [OHHTTPStubs stubHTTPRequestWithNSURL:expectedURL
//                            andHTTPMethod:@"POST"
//                                 matching:OHHTTPMatchAll
//                          withFixtureFile:@"failureResponse.json"
//                               statusCode:200
//                               andHeaders:@{@"Content-Type":@"text/json"}];
//
//    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
//        XCTFail(@"Should not succeed");
//    };
//
//    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
//        dispatch_semaphore_signal(waitSemaphore);
//    };
//
//    [FPLibrary uploadData:data
//                    named:imageFilename
//                   toPath:imageFilename
//               ofMimetype:imageMimetype
//      usingOperationQueue:nil
//                  success:successBlock
//                  failure:failureBlock
//                 progress:nil];
//
//    // Wait for our block to return
//
//    while (dispatch_semaphore_wait(waitSemaphore, DISPATCH_TIME_NOW))
//    {
//        runTheRunLoopOnce();
//    }
//
//    OCMVerifyAll(configMock);
//}

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

    OCMStub([configMock APIKey]).andReturn(@"MY-API-KEY");

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

    NSURL *expectedEndImageURL = [NSURL URLWithString:@"api/pathoutline.png"
                                        relativeToURL:[FPConfig sharedInstance].baseURL];
    [OHHTTPStubs stubHTTPRequestWithNSURL:expectedEndImageURL
                            andHTTPMethod:@"POST"
                                 matching:OHHTTPMatchAll
                          withFixtureFile:@"successfulMultipartSaveasResponse.json"
                               statusCode:200
                               andHeaders:@{@"Content-Type":@"text/json"}];

//https://www.filepicker.io/api/file/Z7aGazYTXiIQTIcHiYgR

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        dispatch_semaphore_signal(waitSemaphore);
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error, id JSON) {
        dispatch_semaphore_signal(waitSemaphore);
        XCTFail(@"Should not fail");
    };

    [FPLibrary uploadData:data
                    named:imageFilename
                   toPath:@""
               ofMimetype:imageMimetype
      usingOperationQueue:nil
                  success:successBlock
                  failure:failureBlock
                 progress:nil];

    // Wait for our block to return

    while (dispatch_semaphore_wait(waitSemaphore, DISPATCH_TIME_NOW))
    {
        runTheRunLoopOnce();
    }

    OCMVerifyAll(configMock);

    // Remove stubs so they are not used by other test cases
    [OHHTTPStubs removeAllStubs];
}

- (void)testFailingMultipartUpload
{
    // TODO: Implement
}

@end
