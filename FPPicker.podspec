# TODO before release:
#
# - Update screenshot URL to point to the master branch
# - Point source to tag 'v3.0.0'

Pod::Spec.new do |s|
  s.name         = 'FPPicker'
  s.version      = '3.0.0'
  s.summary      = 'SDK to access Filepicker.io API'

  s.description  = <<-DESC
    Filepicker helps developers connect with all the data sources they might have.
    This is an SDK that lets developers easily add a bunch of cloud file handling features without coding.
  DESC

  s.homepage     = 'https://github.com/Ink/ios-picker/'
  s.screenshots  = 'https://github.com/Ink/ios-picker/raw/cleanup-for-ios6/Docs/filepicker_ios.png'
  s.license      = { :type => 'MIT', :file => 'license.txt' }

  s.author       = { 'Filepicker.io' => 'contact@filepicker.io' }

  s.source       = {
    :git => 'https://github.com/Ink/ios-picker.git',
    :branch => 'cleanup-for-ios6'
    # :tag => 'v3.0.0'
  }

  s.platforms    = { :ios => '6.0' }

  s.prefix_header_file  = 'FPPicker/FPPicker-Prefix.pch'
  s.public_header_files = 'FPPicker/*.h'
  s.source_files = 'FPPicker/*.{h,m}'

  s.frameworks   = 'AssetsLibrary', 'CoreFoundation', 'CoreGraphics', 'Foundation', 'MobileCoreServices', 'QuartzCore', 'SystemConfiguration'

  s.dependency 'AFNetworking', '~> 2.3.1'

  s.requires_arc = true

  s.resource_bundle = { 'FPPicker' => 'FPPicker Resources/Assets/*.*' }
end
