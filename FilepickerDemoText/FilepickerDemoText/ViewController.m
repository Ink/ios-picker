//
//  ViewController.m
//  FilepickerDemoText
//
//  Created by Liyan David Chang on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize textView = _textView;

#warning Be sure to register for a filepicker apikey at http://filepicker.io and add it to the Supporting Files/FilepickerDemo-Info.plist


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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"begin edit");
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _textView.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-216-44);
    [UIView commitAnimations];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"end edit");
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _textView.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {   
    [textField resignFirstResponder]; 
}



- (IBAction)pickerAction: (id) sender {
    NSLog(@"Picking");
    /*
     * Create the object
     */
    FPPickerController *fpController = [[FPPickerController alloc] init];
    
    /*
     * Set the delegate
     */
    fpController.fpdelegate = self;
    
    /*
     * Ask for specific data types. (Optional) Default is all files.
     */
    fpController.dataTypes = [NSArray arrayWithObjects:@"text/plain", nil];
    
    /*
     * Select and order the sources (Optional) Default is all sources
     */
    //fpController.sourceNames = [[NSArray alloc] initWithObjects: FPSourceImagesearch, nil];
    
    
    /*
     * Display it.
     */
    [self presentViewController:fpController animated:YES completion:nil];
}

- (IBAction)savingAction: (id) sender {
    NSLog(@"Saving");

    /*
     * Create the object
     */
    FPSaveController *fpSave = [[FPSaveController alloc] init];
    
    /*
     * Set the delegate
     */
    fpSave.fpdelegate = self;
    
    /*
     * Select and order the sources (Optional) Default is all sources
     */
    //fpSave.sourceNames = [[NSArray alloc] initWithObjects: FPSourceDropbox, FPSourceFacebook, FPSourceBox, nil];
    
    /*
     * Set the data and data type to be saved.
     */
    fpSave.data = [_textView.text dataUsingEncoding:NSUTF8StringEncoding] ;
    fpSave.dataType = @"text/plain";   //alternative: fpSave.dataExtension = @"txt"
    fpSave.proposedFilename = @"AwesomeFile";
    
    /*
     * Display it.
     */
    [self presentViewController:fpSave animated:YES completion:nil];
}

#pragma mark - FPPickerControllerDelegate Methods

- (void)FPPickerController:(FPPickerController *)picker didPickMediaWithInfo:(NSDictionary *)info {
    
}

- (void)FPPickerController:(FPPickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"FILE CH;OSEN: %@", info);
    
    _textView.text = [NSString stringWithContentsOfURL:[info valueForKey:@"FPPickerControllerMediaURL"] encoding:NSUTF8StringEncoding error:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)FPPickerControllerDidCancel:(FPPickerController *)picker
{
    NSLog(@"FP Cancelled Open");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FPSaveControllerDelegate Methods

- (void)FPSaveControllerDidSave:(FPSaveController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)FPSaveController:(FPSaveController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"FILE SAVED: %@", info);
}
- (void)FPSaveControllerDidCancel:(FPSaveController *)picker {
    NSLog(@"FP Cancelled Save");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)FPSaveController:(FPSaveController *)picker didError:(NSDictionary *)info {
    NSLog(@"FP Error");
}

@end
