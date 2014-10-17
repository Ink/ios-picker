//
//  FPRepresentedSource.h
//  FPPicker
//
//  Created by Ruben Nine on 17/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPSource.h"

@interface FPRepresentedSource : NSObject

/*!
   Parallel operation queue.
   This operation queue supports unlimited simultaneous operations.
 */
@property (nonatomic, strong) NSOperationQueue *parallelOperationQueue;

/*!
   Serial operation queue.
   This operation queue is limited to 1 simultaneous operation.
 */
@property (nonatomic, strong) NSOperationQueue *serialOperationQueue;

/*!
   Represents the current path.
 */
@property (nonatomic, strong) NSString *currentPath;

/*!
   Is the represented source logged in?
   @note This will always be NO if source does not require authentication.
 */
@property (nonatomic, assign) BOOL isLoggedIn;

/*!
   The FPSource being represented.
 */
@property (readonly, strong) FPSource *source;

/**
   Please use the designated initializer instead.
 */
- (id)init __unavailable;

- (id)initWithSource:(FPSource *)source;
- (void)cancelAllOperations;

@end
