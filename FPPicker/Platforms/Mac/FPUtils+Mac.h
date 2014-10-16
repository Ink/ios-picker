//
//  FPUtils+Mac.h
//  FPPicker
//
//  Created by Ruben Nine on 16/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPUtils.h"

@interface FPUtils (Mac)

+ (void)presentError:(NSError *)error
     withMessageText:(NSString *)messageText;

@end
