//
//  FPRepresentedSource.h
//  FPPicker
//
//  Created by Ruben Nine on 17/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPSource.h"
#import "FPSourcePath.h"

@interface FPRepresentedSource : NSObject

/*!
   Parallel operation queue.
   This operation queue supports unlimited simultaneous operations.
 */
@property (readonly, nonatomic, strong) NSOperationQueue *parallelOperationQueue;

/*!
   Serial operation queue.
   This operation queue is limited to 1 simultaneous operation.
 */
@property (readonly, nonatomic, strong) NSOperationQueue *serialOperationQueue;

/*!
   The FPSource being represented.
 */
@property (readonly, nonatomic, strong) FPSource *source;

/*!
   The FPSourcePath being represented.
 */
@property (readonly, nonatomic, strong) FPSourcePath *sourcePath;

/*!
   Represents the current path.
 */
@property (nonatomic, strong) NSString *currentPath;

/*!
   Is the represented source logged in?
   @note This will always be NO if source does not require authentication.
 */
@property (nonatomic, assign) BOOL isLoggedIn;

/**
   Please use the designated initializer instead.
 */
- (id)init __unavailable;

- (id)initWithSource:(FPSource *)source NS_DESIGNATED_INITIALIZER;
- (void)cancelAllOperations;
- (NSString *)rootPath;
- (NSString *)parentPath;

@end
