//
//  FPMacros.h
//  FPPicker
//
//  Created by Ruben Nine on 12/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#define FPCLAMP(x, minimum, maximum) \
    MIN((maximum), MAX((minimum), (x)))

#define NSForceLog(fmt, ...) \
    NSLog((@"[FPPicker Framework] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__);

#ifdef DEBUG

#define NSLog(...) \
    NSLog(__VA_ARGS__);

#define DLog(fmt, ...) \
    NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__);

#define DTrace(fmt, ...) \
    NSLog((@"TRACE %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__);

#else

#define NSLog(...)

#define DLog(...)

#define DTrace(...)

#endif
