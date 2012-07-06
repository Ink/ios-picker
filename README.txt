ios
===

The easiest way to import content into your application. www.filepicker.io

Dependancies
===

- Built targeting iOS 4.3
- XCode 4

- AssetsLibrary.framework
- QuartzCore.framework
- CoreGraphics.framework
- MobileCoreServices.framework
- Foundation.framework
- CoreFoundation.framework


Installation Instructions
===

For iOS Pros:
1. Get an APIKEY
	- Go to www.filepicker.io to register an account
	- Api Keys are typically randomized and 20 characters long.

2. Insert the framework and bundle
	- Download or clone the repository.
	- Under `/library', you'll find `FPPicker.framework` and `FPPicker.bundle`
	- Drag both into your project, typically in your framework folder

3. Settings
	- In your application's info.plist, add the following key/value:
	Key: "Filepicker APIKEY"
	Value: YOUR_API_KEY (from step 1)
	- If this does build, I've had luck adding "-all_load -ObjC" in Build_Settings/Other_Linker_Flags

4. Use it
	- Initialize it:
    FPPickerController *fpController = [[FPPickerController alloc] init];
    fpController.fpdelegate = self;
	- Delegate Methods:
    - (void)FPPickerController:(FPPickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
    - (void)FPPickerControllerDidCancel:(FPPickerController *)picker;



Running the Demo Project:

1. Get an APIKEY
	- Go to www.filepicker.io to register an account
	- Api Keys are typically randomized and 20 characters long.

2. Insert the framework and bundle
	- Download or clone the repository.
	- Open the /Examples/FPDemo.xcodeproj

3. Settings
	- In your application's info.plist, add the following key/value:
	Key: "Filepicker APIKEY"
	Value: YOUR_API_KEY (from step 1)
	- If this does build, I've had luck adding "-all_load -ObjC" in Build_Settings/Other_Linker_Flags

4. Build and Run

