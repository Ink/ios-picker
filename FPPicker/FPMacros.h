//
//  FPMacros.h
//  FPPicker
//
//  Created by Ruben Nine on 12/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

//To turn off logging for prod versions
#ifdef DEBUG
#   define NSForceLog(...) NSLog(__VA_ARGS__);
#   define NSLog(...) NSLog(__VA_ARGS__);
#else
#   define NSForceLog(FORMAT, ...) fprintf(stderr, "[Ink Mobile Framework] %s\n", [[NSString stringWithFormat:FORMAT, ## __VA_ARGS__] UTF8String]);
#   define NSLog(...)
#endif


/// Stick this in code you want to assert if run on the main UI thread.
#define DONT_BLOCK_UI() \
    NSAssert(![NSThread isMainThread], @"Don't block the UI thread please!")

/// Stick this in code you want to assert if run on a background thread.
#define BLOCK_UI() \
    NSAssert([NSThread isMainThread], @"You aren't running in the UI thread!")

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define FPCLAMP(x, minimum, maximum) \
    MIN((maximum), MAX((minimum), (x)))
