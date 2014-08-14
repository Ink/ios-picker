//
//  FPProgressTrackerTests.m
//  FPPicker
//
//  Created by Ruben Nine on 17/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <XCTest/XCTest.h>

// Collaborators
#import "FPProgressTracker.h"

@interface FPProgressTrackerTests : XCTestCase

@end

@interface FPProgressTracker (PrivateInterface)

@property (nonatomic, strong) NSMutableDictionary *progressMap;
@property (atomic) NSInteger count;

@end

@implementation FPProgressTrackerTests

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

- (void)testInitWithObjectCount
{
    FPProgressTracker *progressTracker = [[FPProgressTracker alloc] initWithObjectCount:10];

    XCTAssertEqual(progressTracker.count,
                   10,
                   @"Should be exactly 10");

    XCTAssertTrue([progressTracker.progressMap isKindOfClass:[NSMutableDictionary class]],
                  @"Should be a NSMutableDictionary instance");
}

- (void)testSetProgress
{
    FPProgressTracker *progressTracker = [[FPProgressTracker alloc] initWithObjectCount:10];

    [progressTracker setProgress:1.0f
                          forKey:@(1)];

    XCTAssertEqualObjects(progressTracker.progressMap[@(1)],
                          @(1.0f),
                          @"Should be 1.0f");
}

- (void)testSetProgressBeyondBounds
{
    FPProgressTracker *progressTracker = [[FPProgressTracker alloc] initWithObjectCount:10];

    [progressTracker setProgress:1.23f
                          forKey:@(1)];

    XCTAssertEqualObjects(progressTracker.progressMap[@(1)],
                          @(1.0f),
                          @"Should be 1.0f");

    [progressTracker setProgress:-0.23f
                          forKey:@(2)];

    XCTAssertEqualObjects(progressTracker.progressMap[@(2)],
                          @(0.0f),
                          @"Should be 0.0f");
}

- (void)testCalculateProgress
{
    int numObjects = 10;
    FPProgressTracker *progressTracker = [[FPProgressTracker alloc] initWithObjectCount:numObjects];

    XCTAssertEqual([progressTracker calculateProgress],
                   0.0f,
                   @"Should be zero at startup");

    [progressTracker setProgress:1.00f
                          forKey:@(0)];

    XCTAssertEqual([progressTracker calculateProgress],
                   0.1f,
                   @"Should be 0.1 after one block completed");

    [progressTracker setProgress:1.23f
                          forKey:@(1)];

    XCTAssertEqual([progressTracker calculateProgress],
                   0.2f,
                   @"Should be 0.2 after another block completed");

    for (int c = 2; c < numObjects; c++)
    {
        [progressTracker setProgress:1.00f
                              forKey:@(c)];
    }

    XCTAssertEqual([progressTracker calculateProgress],
                   1.0f,
                   @"Should be 1.0 after completing another 8 blocks");

    [progressTracker setProgress:1.00f
                          forKey:@(numObjects + 1)];

    XCTAssertEqual([progressTracker calculateProgress],
                   1.0f,
                   @"Should still be 1.0 when going beyond object count");
}

@end
