Pod::Spec.new do |s|
  s.name         = "FilepickerSDK"
  s.version      = "2.4.2"
  s.summary      = "FPPicker.framework is the Filepicker.io iOS famework."
  s.homepage     = "https://developers.filepicker.io/docs/ios/"
  s.screenshots  = "https://github.com/Filepicker/ios/raw/master/Documenation%20Files/filepicker_ios.png"
  s.license      = { :type => 'MIT', :file => 'license.txt' }

  s.author       = { "Liyan Chang" => "liyan@filepicker.io" }

  s.source       = {
    :git => 'https://github.com/Filepicker/ios.git',
    :tag => 'v2.4.2'
  }

  s.platform     = :ios

  s.source_files = 'library/FPPicker.framework/Versions/A/Headers/*.h'
  s.preserve_paths = 'library/FPPicker.framework'
  s.frameworks   = 'AssetsLibrary', 'QuartzCore', 'CoreGraphics', 'MobileCoreServices', 'Foundation', 'CoreFoundation', 'FPPicker'
  s.xcconfig     = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/FilepickerSDK/library"' }

  s.requires_arc = true

  s.resource = "library/FPPicker.bundle"
end
