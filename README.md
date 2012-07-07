# Filepicker iOS Library


The easiest way to import content into your application. 
[Filepicker.io](www.filepicker.io)

## Dependancies

- Software
	- Built targeting iOS 4.3
	- XCode 4
	
- Frameworks
	- AssetsLibrary.framework
	- QuartzCore.framework
	- CoreGraphics.framework
	- MobileCoreServices.framework
	- Foundation.framework
	- CoreFoundation.framework


## Installation Instructions


### For iOS Pros:

1. Get an APIKEY
	- Go to [Filepicker.io](www.filepicker.io) to register an account
	- Api Keys are typically randomized and 20 characters long.

2. Insert the framework and bundle
	- Download or clone the repository.
	- Under `/library`, you'll find `FPPicker.framework` and `FPPicker.bundle`
	- Drag both into your project, typically in your framework folder

3. Settings
	- In your application's info.plist, add the following key/value:
	
	```
	Key: "Filepicker APIKEY"
	Value: YOUR_API_KEY (from step 1)
	```
	- If this doesn't build, I've had luck adding `-all_load -ObjC` in `Build_Settings/Other_Linker_Flags`
	- You may need to add additional frameworks
		- AssetsLibrary.framework
		- QuartzCore.framework
		- CoreGraphics.framework
		- MobileCoreServices.framework
		- Foundation.framework
		- CoreFoundation.framework
	

4. Use it
	- Initialize it:
	
	```
    FPPickerController *fpController = [[FPPickerController alloc] init];
    fpController.fpdelegate = self;
	- Delegate Methods:
    - (void)FPPickerController:(FPPickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
    - (void)FPPickerControllerDidCancel:(FPPickerController *)picker;
```


### Running the Demo Project:

1. Get an Api Key:
	- Go to [Filepicker.io](www.filepicker.io) to register an account
	- Api Keys are typically randomized and 20 characters long.

2. Insert the framework and bundle:
	- Download or clone the repository.
	- Open the `/Examples/FPDemo.xcodeproj`

3. Settings:
	- In your application's info.plist, add the following key/value:
	
	```
	Key: "Filepicker APIKEY"
	Value: YOUR_API_KEY (from step 1)
	```

4. Build and Run


### Starting from scratch:

1. Get an Api Key:
	- Go to [Filepicker.io](www.filepicker.io) to register an account
	- Api Keys are typically randomized and 20 characters long.

2. Start a new Project
<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/10.png" alt="AFNetworking" title="New View Project" style="display:block; margin: 10px auto 30px auto;" class="center">
	- File/New/Project or Shift-Apple N
	- Single View Project

<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/10.png" alt="AFNetworking" title="New View Project" style="display:block; margin: 10px auto 30px auto;" class="center">
	- Name: FilepickerDemo
	- Device Family: iPad
	- Use Storyboards: False
	- Use Automatic Reference Counting: True



