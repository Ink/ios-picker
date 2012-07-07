//
//  FPSearchController.h
//  
//
//  Created by Liyan David Chang on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPLibrary.h"
#import "FPSourceController.h"

@interface FPSearchController : FPSourceController <UISearchDisplayDelegate>

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;

@end
