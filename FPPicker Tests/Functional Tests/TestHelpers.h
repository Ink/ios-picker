//
//  TestHelpers.h
//  FPPicker Functional Tests
//
//  Created by Ruben Nine on 11/06/14.
//  Copyright (c) 2014 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import <Foundation/Foundation.h>

/**
   Runs the loop once so the run loop has a chance to process some events
 */
static inline void runTheLoopOnce()
{
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate distantFuture]];
}
