//
//  FPAuthController.h
//  FPPicker Mac
//
//  Created by Ruben Nine on 06/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "FPSource.h"

typedef void (^FPAuthSuccessBlock)(void);
typedef void (^FPAuthFailureBlock)(NSError *__nonnull error);

NS_ASSUME_NONNULL_BEGIN
@interface FPAuthController : NSViewController

- (instancetype)initWithSource:(FPSource *)source;

- (void)displayAuthSheetInModalWindow:(NSWindow *)modalWindow
                              success:(FPAuthSuccessBlock)success
                              failure:(FPAuthFailureBlock)failure;

+ (void)clearAuthCredentials;

@end
NS_ASSUME_NONNULL_END
