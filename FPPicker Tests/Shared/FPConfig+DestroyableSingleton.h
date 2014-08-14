//
//  FPConfig+DestroyableSingleton.h
//  FPPicker
//
//  Created by Ruben Nine on 17/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#include "FPConfig.h"

@interface FPConfig (DestroyableSingleton)

+ (void)destroyAndRecreateSingleton;

@end
