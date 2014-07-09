Pod::Spec.new do |s|
  s.name         = 'FPPicker'
  s.version      = '3.0.2'
  s.summary      = 'SDK to access Filepicker.io API'

  s.description  = <<-DESC
    Filepicker helps developers connect with all the data sources they might have.
    This is an SDK that lets developers easily add a bunch of cloud file handling features without coding.
  DESC

  s.homepage     = 'https://github.com/Ink/ios-picker/'
  s.screenshots  = 'https://github.com/Ink/ios-picker/raw/develop/Docs/filepicker_ios.png'
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }

  s.author       = { 'Filepicker.io' => 'contact@filepicker.io' }

  s.source       = {
    :git => 'https://github.com/Ink/ios-picker.git',
    :tag => 'v3.0.2'
  }

  s.platforms    = { :ios => '6.0' }

  s.prefix_header_file  = 'FPPicker/FPPicker-Prefix.pch'

  s.public_header_files = 'FPPicker/FPConstants.h', 'FPPicker/FPPicker.h', 'FPPicker/FPPickerController.h', 'FPPicker/FPSaveController.h', 'FPPicker/FPExternalHeaders.h'
  s.source_files = 'FPPicker/*.{h,m}'

  s.frameworks   = 'AssetsLibrary', 'CoreFoundation', 'CoreGraphics', 'Foundation', 'MobileCoreServices', 'QuartzCore', 'SystemConfiguration'

  s.dependency 'AFNetworking', '~> 2.3.1'

  s.requires_arc = true

  s.resource_bundle = { 'FPPicker' => 'FPPicker Resources/Assets/*.*' }
end
