Pod::Spec.new do |s|
  s.name         = 'FPPicker'
  s.version      = '4.2.6'
  s.summary      = 'SDK to access Filepicker.io API'

  s.description  = <<-DESC
    Filepicker helps developers connect with all the data sources they might have.
    This is an SDK that lets developers easily add a bunch of cloud file handling features without coding.
  DESC

  s.homepage     = 'https://github.com/Ink/ios-picker/'
  s.screenshots  = 'https://github.com/Ink/ios-picker/raw/develop/Docs/filepicker.png'
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author       = { 'Filepicker.io' => 'contact@filepicker.io' }

  s.source       = {
    :git => 'https://github.com/Ink/ios-picker.git',
    :tag => 'v4.2.6'
  }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.ios.prefix_header_file  = 'Resources-iOS/FPPicker-Prefix.pch'
  s.osx.prefix_header_file  = 'Resources-Mac/FPPicker-Mac-Prefix.pch'

  shared_public_header_files = %w(
    FPPicker/Shared/FPExternalHeaders.h
    FPPicker/Shared/FPConfig.h
    FPPicker/Shared/FPConstants.h
    FPPicker/Shared/FPMediaInfo.h
  )

  s.ios.public_header_files = %w(
    FPPicker/Platforms/iOS/FPPicker.h
    FPPicker/Platforms/iOS/FPPickerController.h
    FPPicker/Platforms/iOS/FPSaveController.h
  ).concat(shared_public_header_files)

  s.osx.public_header_files = %w(
    FPPicker/Platforms/Mac/FPPickerMac.h
    FPPicker/Platforms/Mac/FPPickerController.h
    FPPicker/Platforms/Mac/FPSaveController.h
  ).concat(shared_public_header_files)

  s.ios.source_files = 'FPPicker/Shared/*.{h,m}', 'FPPicker/Platforms/iOS/*.{h,m}'
  s.osx.source_files = 'FPPicker/Shared/*.{h,m}', 'FPPicker/Platforms/Mac/*.{h,m}'

  s.ios.frameworks   = 'AssetsLibrary', 'CoreFoundation', 'CoreGraphics', 'MobileCoreServices', 'QuartzCore', 'SystemConfiguration'
  s.osx.frameworks   = 'WebKit', 'Quartz'

  s.dependency 'AFNetworking', '~> 2.5.3'
  s.ios.dependency 'MBProgressHUD', '~> 0.9'

  s.requires_arc = true

  s.ios.resource_bundle = { 'FPPicker' => 'Resources-Shared/*.*' }
  s.osx.resource_bundle = { 'FPPicker' => 'Resources-Shared/*.*', 'FPPickerMac' => 'Resources-Mac/*.*' }
end
