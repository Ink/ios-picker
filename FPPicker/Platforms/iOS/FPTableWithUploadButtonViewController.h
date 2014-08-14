//
//  FPTableWithUploadButtonViewController.h
//  FPPicker
//
//  Created by Brett van Zuiden on 12/3/13.
//  Copyright (c) 2013 Filepicker.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FPTableWithUploadButtonViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) BOOL selectMultiple;
@property (nonatomic) NSInteger maxFiles;

- (void)updateUploadButton:(NSInteger)count;
- (IBAction)uploadButtonTapped:(id)sender;

@end
