//
//  FPMacros.h
//  FPPicker
//
//  Created by Ruben Nine on 12/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPConfig.h"

#define FPCLAMP(x, minimum, maximum) \
    MIN((maximum), MAX((minimum), (x)))

#define FPLog(level, fmt, ...) \
    [FPConfig logMessage:[NSString stringWithFormat:(@"[FPPicker Framework] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__] logLevel:level];

#define FPLogError(fmt, ...) FPLog(FPErrorLogLevel, fmt, ## __VA_ARGS__)
#define FPLogInfo(fmt, ...) FPLog(FPInfoLogLevel, fmt, ## __VA_ARGS__)

