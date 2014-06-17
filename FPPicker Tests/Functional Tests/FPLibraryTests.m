//
//  FPLibraryTests.m
//  FPPicker
//
//  Created by Ruben Nine on 17/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import <XCTest/XCTest.h>

// Collaborators
#import "FPConfig.h"
#import "FPLibrary.h"
#import "FPAFHTTPClient.h"

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

- (void)testUploadDataToFilePickerWithSinglepartUpload
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
    NSData *smallImage = [NSData dataWithBytes:smallImageBuffer
                                        length:smallImageSize];

    id NSDataMock = OCMClassMock([NSData class]);

    OCMStub([NSDataMock dataWithContentsOfURL:[OCMArg any]]).andReturn(smallImage);

    [FPLibrary uploadDataToFilepicker:[NSURL URLWithString:@""]
                                named:@"chunkyImage.png"
                           ofMimetype:@"image/png"
                         shouldUpload:YES
                              success:nil
                              failure:nil
                             progress:nil];

    free(smallImageBuffer);

    OCMVerifyAll(FPLibraryMock);
    OCMVerifyAll(NSDataMock);
}

- (void)testUploadDataToFilePickerWithMultipartUpload
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
    NSData *largeImage = [NSData dataWithBytes:largeImageBuffer
                                        length:largeImageSize];

    id NSDataMock = OCMClassMock([NSData class]);

    OCMStub([NSDataMock dataWithContentsOfURL:[OCMArg any]]).andReturn(largeImage);

    [FPLibrary uploadDataToFilepicker:[NSURL URLWithString:@""]
                                named:@"chunkyImage.png"
                           ofMimetype:@"image/png"
                         shouldUpload:YES
                              success:nil
                              failure:nil
                             progress:nil];

    free(largeImageBuffer);

    OCMVerifyAll(FPLibraryMock);
    OCMVerifyAll(NSDataMock);
}

- (void)testSucessfulSinglepartUpload
{
    dispatch_semaphore_t waitSemaphore = dispatch_semaphore_create(0);
    id configMock = OCMPartialMock([FPConfig sharedInstance]);
    id httpClientMock = OCMClassMock([FPAFHTTPClient class]);

    OCMStub([configMock APIKeyContentsFromFile]).andReturn(@"MY_FAKE_API_KEY");

    NSString *imageFilename = @"outline.png";
    NSString *imageMimetype = @"image/png";
    NSString *imageFixtureFilepath = OHPathForFileInBundle(imageFilename, nil);
    NSData *data = [NSData dataWithContentsOfFile:imageFixtureFilepath];

    XCTAssertTrue(data.length > 0, @"Fixture data expected");

    [OHHTTPStubs stubHTTPRequestAndResponseWithHost:@"dialog.filepicker.io"
                                               path:@"/api/path/computer"
                                             scheme:@"https"
                                         HTTPMethod:@"POST"
                                        fixtureFile:@"sucessfulResponse.json"
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

    OCMVerifyAll(httpClientMock);
    OCMVerifyAll(configMock);
}

- (void)testFailingSinglepartUpload
{
    dispatch_semaphore_t waitSemaphore = dispatch_semaphore_create(0);
    id configMock = OCMPartialMock([FPConfig sharedInstance]);
    id httpClientMock = OCMClassMock([FPAFHTTPClient class]);

    OCMStub([configMock APIKeyContentsFromFile]).andReturn(@"MY_FAKE_API_KEY");

    NSString *imageFilename = @"outline.png";
    NSString *imageMimetype = @"image/png";
    NSString *imageFixtureFilepath = OHPathForFileInBundle(imageFilename, nil);
    NSData *data = [NSData dataWithContentsOfFile:imageFixtureFilepath];

    XCTAssertTrue(data.length > 0, @"Fixture data expected");

    [OHHTTPStubs stubHTTPRequestAndResponseWithHost:@"dialog.filepicker.io"
                                               path:@"/api/path/computer"
                                             scheme:@"https"
                                         HTTPMethod:@"POST"
                                        fixtureFile:@"failureResponse.json"
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

    OCMVerifyAll(httpClientMock);
    OCMVerifyAll(configMock);
}

@end
