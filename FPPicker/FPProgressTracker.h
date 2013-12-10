//
//  FPProgressTracker.h
//  FPPicker
//
//  Created by Brett van Zuiden on 12/9/13.
//  Copyright (c) 2013 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPProgressTracker : NSObject

- (id) initWithObjectCount:(NSInteger)objectCount;

//Updates the progress map for the given key and returns the current total progress
- (float) setProgress:(float)progress forKey:(id<NSCopying>)key;

- (float) calculateProgress;

@end
