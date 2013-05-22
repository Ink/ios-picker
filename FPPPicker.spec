Pod::Spec.new do |s|
  s.name         = "FPPPicker"
  s.version      = "2.4.1"
  s.summary      = "FPPPicker.framework is the Filepicker.io iOS famework."
  s.homepage     = "http:///www.filepicker.io.com"

  s.license      = {
    :type => 'Commercial',
    :text => <<-LICENSE
              © 2012-2013 "Replace". All rights reserved.
    LICENSE
  }
 
  s.author       = { "Replace with name" => "replace with meail" }
  
  s.source       = { :http => 'https://github.com/Filepicker/ios/archive/master.zip' }
 
  s.platform     = :ios, '5.0'
 
  s.source_files = 'FPPPicker.framework/Versions/A/Headers/FPPPicker.h'
  s.preserve_paths = 'FPPPicker.framework/*'
  s.frameworks   = 'FPPPicker', 'AssetsLibrary', 'QuartzCore', 'CoreGraphics', 'MobileCoreServices', 'Foundation', 'CoreFoundation'
  s.xcconfig     = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/XRay"' }
  
  s.requires_arc = false
  
  s.resource = "FPPPicker.bundle"
end
