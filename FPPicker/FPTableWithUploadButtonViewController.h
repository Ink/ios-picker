//
//  FPTableWithUploadButtonViewController.h
//  FPPicker
//
//  Created by Brett van Zuiden on 12/3/13.
//  Copyright (c) 2013 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FPTableWithUploadButtonViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UITableView* tableView;
@property (nonatomic) BOOL selectMultiple;
@property (nonatomic) NSInteger maxFiles;

- (void) updateUploadButton:(NSInteger) count;
- (void) uploadButtonTapped:(id)sender;

@end
