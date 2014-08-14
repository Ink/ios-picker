//
//  FPiOSMacros.h
//  FPPicker
//
//  Created by Ruben Nine on 13/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#define DONT_BLOCK_UI() \
    NSAssert(![NSThread isMainThread], @"Don't block the UI thread please!")

#define BLOCK_UI() \
    NSAssert([NSThread isMainThread], @"You aren't running in the UI thread!")

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)

#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
