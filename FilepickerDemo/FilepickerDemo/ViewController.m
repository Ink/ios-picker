//
//  ViewController.m
//  Filepicker Demo
//
//  Created by Liyan David Chang on 7/5/12.
//  Copyright (c) 2012 filepicker.io (Cloudtop Inc). All rights reserved.
//

#import "ViewController.h"
#import <FPPicker/FPPicker.h>

@interface ViewController ()

@end

@implementation ViewController

@synthesize image, popoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)pickerAction: (id) sender {
    
    
    FPPickerController *fpController = [[FPPickerController alloc] init];
    fpController.fpdelegate = self;
    //fpController.sourceNames = [[NSArray alloc] initWithObjects: (NSString *) FPSourceDropbox, (NSString *) FPSourceImagesearch, nil];
    
    UIPopoverController *popoverControllerA = [UIPopoverController alloc];
    
    self.popoverController = [popoverControllerA initWithContentViewController:fpController];
    popoverController.popoverContentSize = CGSizeMake(320, 520);
    [popoverController presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)FPPickerController:(FPPickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"FILE CHOSEN: %@", info);
    
    image.image = [info objectForKey:@"FPPickerControllerOriginalImage"];
    [popoverController dismissPopoverAnimated:YES];
    
}
- (void)FPPickerControllerDidCancel:(FPPickerController *)picker
{
    NSLog(@"FP Canceled.");
    //[picker removeFromParentViewController];
    [popoverController dismissPopoverAnimated:YES];
}

@end
