//
//  NavigationController.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import "FPSaveController.h"
#import "FPInternalHeaders.h"
#import "FPTheme.h"
#import "FPThemeApplier.h"

@interface FPSaveController () <UINavigationControllerDelegate,
                                UIPopoverControllerDelegate,
                                FPSourceControllerDelegate>

@property (nonatomic, strong) NSOperationQueue *uploadOperationQueue;
@property (nonatomic, strong) FPThemeApplier *themeApplier;

@end

@implementation FPSaveController

#pragma mark - Accessors

- (void)setTheme:(FPTheme *)theme
{
    _theme = theme;

    // Apply theme
    self.themeApplier = [[FPThemeApplier alloc] initWithTheme:theme];

    if (self.isViewLoaded)
    {
        [self.themeApplier applyToController:self];
    }
}

- (NSOperationQueue *)uploadOperationQueue
{
    if (!_uploadOperationQueue)
    {
        _uploadOperationQueue = [NSOperationQueue new];
    }

    return _uploadOperationQueue;
}

#pragma mark - Constructors / Destructor

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];

    return self;
}

#pragma mark - Other Methods

- (void)viewDidLoad
{
    [self.themeApplier applyToController:self];
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.delegate = self;

    if (!fpAPIKEY ||
        [fpAPIKEY isEqualToString:@""] ||
        [fpAPIKEY isEqualToString:@"SET_FILEPICKER.IO_APIKEY_HERE"])
    {
        NSException *apikeyException = [NSException
                                        exceptionWithName:@"Filepicker Configuration Error"
                                                   reason:@"APIKEY not set. You can get one at https://www.filepicker.io and insert it into your project's info.plist as 'Filepicker API Key'"
                                                 userInfo:nil];
        [apikeyException raise];
    }

    if (!self.data &&
        !self.dataurl)
    {
        NSLog(@"WARNING: No data specified. Continuing but saving blank file.");
        self.data = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    }

    if (!self.dataType &&
        !self.dataExtension)
    {
        NSLog(@"WARNING: No data type or data extension specified");
    }

    FPSourceListController *fpSourceListController = [FPSourceListController new];

    fpSourceListController.fpdelegate = self;
    fpSourceListController.sourceNames = self.sourceNames;
    fpSourceListController.dataTypes = @[self.dataType];

    [self pushViewController:fpSourceListController
                    animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.uploadOperationQueue.suspended = NO;

    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.uploadOperationQueue.suspended = YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)saveFileName:(NSString *)filename
                  To:(NSString *)path
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view
                                              animated:YES];

    hud.mode = MBProgressHUDModeDeterminate;
    hud.labelText = @"Uploading...";

    DLog(@"Saving %@%@ to %@", filename, [self getExtensionString], path);

    filename = [filename stringByAppendingString:[self getExtensionString]];

    FPUploadAssetSuccessBlock successBlock = ^(id JSON) {
        [MBProgressHUD hideAllHUDsForView:self.view
                                 animated:YES];

        if (self.fpdelegate &&
            [self.fpdelegate respondsToSelector:@selector(fpSaveController:didFinishSavingMediaWithInfo:)])
        {
            [self.fpdelegate fpSaveController:self
                 didFinishSavingMediaWithInfo:nil];
        }
    };

    FPUploadAssetFailureBlock failureBlock = ^(NSError *error,
                                               id JSON) {
        [MBProgressHUD hideAllHUDsForView:self.view
                                 animated:YES];

        if (self.fpdelegate &&
            [self.fpdelegate respondsToSelector:@selector(fpSaveController:didError:)])
        {
            [self.fpdelegate fpSaveController:self
                                     didError:error];
        }
        else
        {
            [self.fpdelegate fpSaveControllerDidCancel:self];
        }
    };

    FPUploadAssetProgressBlock progressBlock = ^(float progress) {
        hud.progress = progress;
    };

    [self.uploadOperationQueue cancelAllOperations];

    if (self.dataurl)
    {
        [FPLibrary uploadDataURL:self.dataurl
                           named:filename
                          toPath:path
                      ofMimetype:self.dataType
             usingOperationQueue:self.uploadOperationQueue
                         success:successBlock
                         failure:failureBlock
                        progress:progressBlock];
    }
    else
    {
        [FPLibrary uploadData:self.data
                        named:filename
                       toPath:path
                   ofMimetype:self.dataType
          usingOperationQueue:self.uploadOperationQueue
                      success:successBlock
                      failure:failureBlock
                     progress:progressBlock];
    }
}

- (void)saveFileLocally
{
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];

    if (self.dataurl)
    {
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithContentsOfFile:[self.dataurl absoluteString]], nil, nil, nil);
    }
    else
    {
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:self.data], nil, nil, nil);
    }

    if (self.fpdelegate &&
        [self.fpdelegate respondsToSelector:@selector(fpSaveController:didFinishSavingMediaWithInfo:)])
    {
        [self.fpdelegate fpSaveController:self
             didFinishSavingMediaWithInfo:nil];
    }
}

#pragma mark FPSourcePickerDelegate Methods

- (void)sourceController:(FPSourceController *)sourceController
    didPickMediaWithInfo:(FPMediaInfo *)info
{
    // NO-OP
}

- (void)         sourceController:(FPSourceController *)sourceController
    didFinishPickingMediaWithInfo:(FPMediaInfo *)info
{
    // The user saved a file to the cloud or camera roll.

    if (self.fpdelegate &&
        [self.fpdelegate respondsToSelector:@selector(fpSaveController:didFinishSavingMediaWithInfo:)])
    {
        [self.fpdelegate fpSaveController:self
             didFinishSavingMediaWithInfo:nil];
    }
}

- (void)                    sourceController:(FPSourceController *)sourceController
    didFinishPickingMultipleMediaWithResults:(NSArray *)results
{
    // NO-OP
}

- (void)sourceControllerDidCancel:(FPSourceController *)sourceController
{
    //The user chose to cancel when saving to the cloud or camera roll.

    if (self.fpdelegate &&
        [self.fpdelegate respondsToSelector:@selector(fpSaveControllerDidCancel:)])
    {
        [self.fpdelegate fpSaveControllerDidCancel:self];
    }
}

#pragma mark UIPopoverControllerDelegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self.fpdelegate fpSaveControllerDidCancel:self];
}

#pragma mark UINavigationControllerDelegate Methods

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    return;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    return;
}

- (NSString *)getExtensionString
{
    if (self.dataExtension)
    {
        return [NSString stringWithFormat:@".%@", self.dataExtension];
    }
    else if (self.dataType)
    {
        CFStringRef mimeType = (__bridge CFStringRef)self.dataType;
        CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType, NULL);
        CFStringRef extension = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension);
        CFRelease(uti);

        if (extension)
        {
            return [NSString stringWithFormat:@".%@", (__bridge_transfer NSString *)extension];
        }
        else
        {
            return @"";
        }
    }
    else
    {
        return @"";
    }
}

@end
