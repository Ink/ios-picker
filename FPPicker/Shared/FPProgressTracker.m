//
//  FPProgressTracker.m
//  FPPicker
//
//  Created by Brett van Zuiden on 12/9/13.
//  Copyright (c) 2013 Filepicker.io. All rights reserved.
//

#import "FPProgressTracker.h"

@interface FPProgressTracker ()

@property (nonatomic, strong) NSMutableDictionary *progressMap;
@property (atomic) NSInteger count;

@end

@implementation FPProgressTracker

- (id)initWithObjectCount:(NSInteger)objectCount
{
    self = [self init];

    if (self)
    {
        self.progressMap = [NSMutableDictionary dictionary];
        self.count = objectCount;
    }

    return self;
}

- (float)setProgress:(float)progress forKey:(id<NSCopying>)key
{
    float clampedProgress = FPCLAMP(progress, 0.0f, 1.0f);

    if(key == nil){
        NSLog(@"Invalid progress key");
        return 0;
    }
    
    if (progress != clampedProgress)
    {
        NSLog(@"Invalid progress: %f, bounding", progress);
    }

    self.progressMap[key] = @(clampedProgress);

    return [self calculateProgress];
}

- (float)calculateProgress
{
    float totalProgress = 0;

    for (id<NSCopying> key in self.progressMap)
    {
        NSNumber *val = self.progressMap[key];

        if (val)
        {
            totalProgress += val.floatValue;
        }
    }

    return FPCLAMP(totalProgress / self.count, 0.0f, 1.0f);
}

@end
