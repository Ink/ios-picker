Pod::Spec.new do |s|
  s.name         = "FilepickerSDK"
  s.version      = "2.4.2"
  s.summary      = "FPPicker.framework is the Filepicker.io iOS famework."
  s.homepage     = "https://developers.filepicker.io/docs/ios/"
  s.screenshots  = "https://github.com/Filepicker/ios/raw/master/Documenation%20Files/filepicker_ios.png"
  s.license      = { :type => 'MIT', :file => 'license.txt' }

  s.author       = { "Liyan Chang" => "liyan@filepicker.io" }

  s.source       = {
    :git => 'https://github.com/escherba/ios-picker.git',
    :tag => 'v2.4.2'
  }

  s.platform     = :ios
  s.ios.deployment_target = '6.0'
  s.ios.prefix_header_file = 'FPPicker/FPPicker-Prefix.pch'
  s.source_files = 'FPPicker/*.{h,m}'
  s.resources = "FPPicker/*.{png,plist}"
  #s.preserve_paths = 'library/FPPicker.framework'
  s.frameworks   = 'AssetsLibrary', 'QuartzCore', 'CoreGraphics', 'MobileCoreServices', 'Foundation', 'CoreFoundation', 'FPPicker'
  #s.xcconfig     = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/FilepickerSDK/library"' }

  s.requires_arc = false
  s.subspec 'arc' do |sp|
    sp.requires_arc = true
    sp.dependency 'AFNetworking', '~> 2.2.1'
  end
  s.subspec 'no-arc' do |sp|
    sp.requires_arc = false
    sp.dependency 'LFJSONKit', '~> 1.6a'
  end
end
