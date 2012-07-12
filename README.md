# Filepicker iOS Library


The easiest way to import content into your application. 
[Filepicker.io](www.filepicker.io)

<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/filepicker_ios.png" class="center">

## Dependancies

- Software
	- Built targeting iOS 4.3
	- XCode 4
	
- Frameworks
	- AssetsLibrary.framework
	- QuartzCore.framework
	- CoreFoundation.framework
	- MobileCoreServices.framework
	- CoreGraphics.framework
	- Foundation.framework
	- UIKit.framework
	
- Other Linked Libraries
 	- AFNetworking (https://github.com/AFNetworking/AFNetworking/)
	- JSONkit (https://github.com/johnezang/JSONKit/)
	- MBProgressHUD (https://github.com/jdg/MBProgressHUD)
	- FP_PullRefresehTabelViewController (Forked from: https://github.com/leah/PullToRefresh)

## Usage Instructions

#### Importing

```
	#import <FPPicker/FPPicker.h>
```

#### Opening Files
```	
    // To create the object
    FPPickerController *fpController = [[FPPickerController alloc] init];
    
    // Set the delegate
    fpController.fpdelegate = self;
    
	// Ask for specific data types. (Optional) Default is all files.
    fpController.dataTypes = [NSArray arrayWithObjects:@"text/plain", nil];
    
	// Select and order the sources (Optional) Default is all sources
	fpController.sourceNames = [[NSArray alloc] initWithObjects: FPSourceImagesearch, FPSourceDropbox, nil];
    
    // Display it.
    [self presentModalViewController:fpController animated:YES];
```

#### Saving Files

```    
    // To create the object
    FPSaveController *fpSave = [[FPSaveController alloc] init];
    
    // Set the delegate
    fpSave.fpdelegate = self;
    
	// Ask for specific data mimetypes. (Optional) Default is all files.
    fpController.dataTypes = [NSArray arrayWithObjects:@"text/plain", nil];
    
	// Select and order the sources (Optional) Default is all sources
	//fpSave.sourceNames = [NSArray arrayWithObjects: FPSourceCamera, FPSourceCameraRoll, FPSourceDropbox, FPSourceFacebook, FPSourceGmail, FPSourceBox, FPSourceGithub, FPSourceGoogleDrive, FPSourceImagesearch, nil];
	
    // Set the data and data type to be saved.
    fpSave.data = [[NSData *alloc] init] ;
    fpSave.dataType = @"text/plain";   
    //alternative: fpSave.dataExtension = @"txt"
    
    //optional: propose the default file name
    fpSave.proposedFilename = @"AwesomeFile";
	
    // Display it.
    [self presentModalViewController:fpController animated:YES];
```

### Delegate Functions

####FPPickerControllerDelegate

`- (void)FPPickerController:(FPPickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;`

- Keys in the info dictionary
	- FPPickerControllerMediaType 
		- the UTType of the file 
		- e.g: `public.image`
	- FPPickerControllerReferenceURL 
		- The local location of the file.
		- e.g: `assets-library://asset/asset.JPG?id=1000000001&ext=JPG`
	- FPPickerControllerRemoteURL 
		- The URL for the file. 
		- e.g: https://www.filepicker.io/api/file/we9f3kf93qls0)
		- These will be active for 4 hours or permanent, depending on your filepicker plan
	- (When Possible) FPPickerControllerOriginalImage 
		- The UIImage
		- e.g: `<UIImage: 0x8a37730>`

`- (void)FPPickerControllerDidCancel:(FPPickerController *)picker`

####FPSaveControllerDelegate Methods

`- (void)FPSaveController:(FPSaveController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;`
* IMPORTANT NOTE: Info is an empty dictionary; nothing is being passed back 

`- (void)FPSaveControllerDidCancel:(FPSaveController *)picker;`

####List of all sources:

- Complete Listing
	- FPSourceCamera
		- The Local Camera
		- Open: "image/jpeg", "image/png"
		- Save: nil
	- FPSourceCameraRoll
		- The Local Photos
		- Open: "image/jpeg", "image/png", "video/quicktime"
		- Save: "image/jpeg", "image/png"
	- FPSourceDropbox
		- www.dropbox.com
		- Open: "\*/*"
		- Save: "\*/*"
	- FPSourceFacebook
		- www.facebook.com
		- Open: "image/jpeg"
		- Save: "image/*"
	- FPSourceGmail
		- www.gmail.com
		- Open: "\*/*"
		- Save: nil
	- FPSourceBox
		- www.box.com
		- Open: "\*/*"
		- Save: "\*/*"
	- FPSourceGithub
		- www.github.com
		- Open: "\*/*"
		- Save: nil
	- FPSourceGoogleDrive
		- drive.google.com
		- Open: "\*/*"
		- Save: "\*/*"
	- FPSourceImagesearch
		- Flickr Public Domain Image Search
		- Open: "image/jpeg"
		- Save: nil
		

## Common tips

1. #### The App builds, but crashes: 
	`Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'No JSON parsing functionality available'`
	`'NSInvalidArgumentException', reason: '-[UIImageView setImageWithURLRequest:placeholderImage:success:failure:]: `

	These are likely because JSONKit or AFNetworking are not linked. One fix for this is to add  `-all_load` to `Build Settings/Other Linker Flags`. This will link the libraries that Filepicker needs.

2. #### The app doesn't build: `Duplicate symbol _AFURLEncodedStringFromStringWithEncoding` or similar

	You probabably are using AFNetworking. Since Filepicker depends on it, the compiler is adding AFNetworking twice and complaining. If you have a similar `Duplicate symbol` issue, it may be that you are using `JSONkit` or `MBProgressHUD`.

	While this issue seems to be solved for [XCode 4.4 Developer Preview 5 and beyond](https://github.com/CocoaPods/CocoaPods/issues/322), the solution is to use the filepicker library without external libraries, then adding your own.

	In `/library - no attached libraries/`, you'll find a version of the library that was not linked. Import this one instead, but make sure that you fulfill all the dependancies. JSONKit, MBProgressHUD, and AFNetworking are also in that folder for your convenience. 

3. #### The app builds, but crashes when I try to present the modal
	It may be that you haven't set your apikey as it's checked the first time it's loaded.
	- Go to www.filepicker.io and register.
	- In your application's info.plist, add the following key/value:
	
	```
	Key: "Filepicker API Key"
	Value: YOUR_API_KEY (that you got from registering)
	```



## Installation Instructions


### For iOS Pros:

1. Get an API Key
	- Go to [Filepicker.io](www.filepicker.io) to register an account
	- Api Keys are typically randomized and 20 characters long.

2. Insert the framework and bundle
	- Download or clone the repository.
	- Under `/library`, you'll find `FPPicker.framework` and `FPPicker.bundle`
	- Drag both into your project, typically in your framework folder
	- `#import <FPPicker/FPPicker.h>` in your `viewController.h` or other file where you want to use it.
		<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/35.png" class="center">


3. Settings
	- In your application's info.plist, add the following key/value:
	
	```
	Key: "Filepicker API Key"
	Value: YOUR_API_KEY (that you got from step 1)
	```
	- If this doesn't build, I've had luck adding `-all_load -ObjC` in `Build_Settings/Other_Linker_Flags`
	- You may need to add additional frameworks
		- AssetsLibrary.framework
		- QuartzCore.framework
		- CoreFoundation.framework
		- MobileCoreServices.framework
		- CoreGraphics.framework
		- Foundation.framework
		- UIKit.framework

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
	
		<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/150.png" class="center">

	
	```
	Key: "Filepicker API Key"
	Value: YOUR_API_KEY (that you got from step 1)
	```

4. Build and Run


### Starting from scratch:

1. Get an Api Key:
	- Go to [Filepicker.io](www.filepicker.io) to register an account
	- Api Keys are typically randomized and 20 characters long.

2. Start a new Project
	<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/10.png" class="center">
	- File/New/Project or Shift-Apple N
	- Single View Project
	
	<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/20.png" class="center">
	- Name: FilepickerDemo
	- Device Family: iPad
	- Use Storyboards: False
	- Use Automatic Reference Counting: True
	
2. Insert the framework and bundle
	- Download or clone the repository.
	<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/30.png" class="center">
	- You can do this at the top of this git repository with either `ZIP` to get the zip or `git clone https://github.com/Filepicker/ios.git`.
	- Open up the folder.
	- Under `library/`, you'll find `FPPicker.framework` and `FPPicker.bundle`
	<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/35.png" class="center">	
	- Drag both into your project, typically in your framework folder
	<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/40.png" class="center">	
	- Choose to `Copy items into Destination Folder`
	
	
3. Adding Additional Frameworks

	<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/45.png" class="center">	
	- Click on the .xcodeProj
	<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/50.png" class="center">	
	<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/60.png" class="center">	
	- Under `Build Phases -> Link Binary with Libraries`, add the following:
		- AssetsLibrary.framework
		- QuartzCore.framework
		- CoreGraphics.framework
		- MobileCoreServices.framework
		- Foundation.framework
		- CoreFoundation.framework
	<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/70.png" class="center">	
	- Under `Build Settings`, search for `Other Linker Flags` and set it to -all_load
	<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/75.png" class="center">	


4. Write the code
	- You can copy and paste the following code into your `ViewController.h` and `ViewController.m` respectively.
	- In `ViewController.h`
		- We create a button, imageview, and a popover
	- In `ViewController.m`
		- We create an action when the button is pressed
		- We also have two delegates that respond when the Filepicker is finished.
	- [ViewController.h Source](https://github.com/Filepicker/ios/blob/master/FilepickerDemo/FilepickerDemo/ViewController.h)
	- [ViewController.m Source](https://github.com/Filepicker/ios/blob/master/FilepickerDemo/FilepickerDemo/ViewController.m)
	
6. Build the User Interface
	- Drag a 'Image View' and a 'Rounded Rectangle Button' from the objects draw on the right.
	<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/110.png" class="center">	
	- Hook up the proper interfaces
		- On the right hand side, you'll notice three icons, one of which is the `File's Owner`
		<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/115.png" class="center">	
		- Hold down Ctrl, click and hold down the File Owner Orange Cube, then drag to the Image. A small popup will ask you to connect the file owner to the image. Choose `Outlet: Image`.
		- In a similar manner, ctrl drag from File Owner -> Button. Choose `Outlet: Button`.
		- Now, in the opposite direction, ctrl dragging from the button to the file owner. Choose `pickerAction:`.
		- Now if you right click on file owner, you should see the following.
		<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/140.png" class="center">
	
7. Add your API Key
	- Go to `Supporting Files/FilepickerDemo-Info.plist`. (Your's may vary if you didn't name it FilepickerDemo).
	- Right click, `Add Row`.
	- For the key: `Filepicker API Key`
	- For the value, paste in your apikey that you got from filepicker.io
	<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/150.png" class="center">
	
8. Run.
	- Click the `run` button in the upper right corner of xcode.
	- It should build and you can now choose a file!
	<img src="https://github.com/Filepicker/ios/raw/master/Documenation%20Files/160.png" class="center">
	