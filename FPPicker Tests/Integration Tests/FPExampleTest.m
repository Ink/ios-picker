//
//  TLDExampleTest.m
//  FPPicker
//
//  Created by Ruben Nine on 12/06/14.
//  Copyright (c) 2014 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import <Subliminal/Subliminal.h>
#import "ViewController.h"

@interface FPExampleTest : SLTest

@end

@implementation FPExampleTest

- (void)setUpTest
{
    // Navigate to the part of the app being exercised by the test cases,
    // initialize SLElements common to the test cases, etc.
}

- (void)tearDownTest
{
    // Navigate back to "home", if applicable.
}

- (void)testButtonPresenceAndVisibility
{
    SLElement *selectImageButton = [SLElement elementWithAccessibilityLabel:kSelectImageButtonAccesibilityLabel];
    SLElement *saveImageButton = [SLElement elementWithAccessibilityLabel:kSaveImageButtonAccesibilityLabel];

    SLAssertTrue(selectImageButton, @"Button should be present");
    SLAssertTrue(saveImageButton, @"Button should be present");

    SLAssertTrue(selectImageButton.isVisible, @"Button should be visible");
    SLAssertTrue(saveImageButton.isVisible, @"Button should be visible");
}

@end
