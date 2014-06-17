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

    FPUploadAssetProgressBlock progressBlock = ^(float progress) {};

    [FPLibrary singlepartUploadData:data
                              named:imageFilename
                         ofMimetype:imageMimetype
                            success:successBlock
                            failure:failureBlock
                           progress:progressBlock];

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

    FPUploadAssetProgressBlock progressBlock = ^(float progress) {};

    [FPLibrary singlepartUploadData:data
                              named:imageFilename
                         ofMimetype:imageMimetype
                            success:successBlock
                            failure:failureBlock
                           progress:progressBlock];

    // Wait for our block to return

    while (dispatch_semaphore_wait(waitSemaphore, DISPATCH_TIME_NOW))
    {
        runTheRunLoopOnce();
    }

    OCMVerifyAll(httpClientMock);
    OCMVerifyAll(configMock);
}

@end
