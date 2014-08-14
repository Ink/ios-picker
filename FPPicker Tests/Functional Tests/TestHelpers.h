//
//  TestHelpers.h
//  FPPicker Functional Tests
//
//  Created by Ruben Nine on 11/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

// Mocking, stubbing classes

#import "OCMock.h"
#import "OHHTTPStubs.h"

// Categories

#import "NSDictionary+FPMerge.h"
#import "OHHTTPStubs+ConveniencyMethods.h"
#import "FPConfig+DestroyableSingleton.h"


/**
   Runs the loop once so the run loop has a chance to process some events
 */
static inline void runTheRunLoopOnce()
{
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate distantFuture]];
}
