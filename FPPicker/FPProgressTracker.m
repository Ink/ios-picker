//
//  FPProgressTracker.m
//  FPPicker
//
//  Created by Brett van Zuiden on 12/9/13.
//  Copyright (c) 2013 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPProgressTracker.h"

@interface FPProgressTracker ()
@property (nonatomic, strong) NSMutableDictionary *progressMap;
@property (atomic) NSInteger count;
@end

@implementation FPProgressTracker
@synthesize progressMap;
@synthesize count;

- (id) initWithObjectCount:(NSInteger)objectCount {
    self = [super init];
    if (self) {
        self.progressMap = [[NSMutableDictionary alloc] init];
        self.count = objectCount;
    }
    return self;
}

- (float) setProgress:(float)progress forKey:(id<NSCopying>)key {
    if (progress < 0 || progress > 1.f) {
        NSLog(@"Invalid progress: %f, bounding", progress);
    }
    progress = fmaxf(fminf(progress, 1.f), 0.0f);
    [self.progressMap setObject:[NSNumber numberWithFloat:progress] forKey:key];
    return [self calculateProgress];
}

- (float) calculateProgress {
    float totalProgress = 0;
    for (id<NSCopying> key in self.progressMap) {
        NSNumber *val = [self.progressMap objectForKey:key];
        if (val) {
            totalProgress += val.floatValue;
        }
    }
    return fmaxf(fminf(totalProgress/self.count, 1.f), 0.0f);
}

@end
