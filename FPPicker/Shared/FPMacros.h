//
//  FPMacros.h
//  FPPicker
//
//  Created by Ruben Nine on 12/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#define FPCLAMP(x, minimum, maximum) \
    MIN((maximum), MAX((minimum), (x)))

#ifdef DEBUG

#define NSForceLog(...) \
    NSLog(__VA_ARGS__);

#define NSLog(...) \
    NSLog(__VA_ARGS__);

#define DLog(fmt, ...) \
    NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__);

#define DTrace(fmt, ...) \
    NSLog((@"TRACE %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__);

#else

#define NSForceLog(FORMAT, ...) \
    fprintf(stderr, "[Ink Mobile Framework] %s\n", [[NSString stringWithFormat:FORMAT, ## __VA_ARGS__] UTF8String]);

#define NSLog(...)

#define DLog(...)

#define DTrace(...)

#endif
