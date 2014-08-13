workspace 'FPPicker.xcworkspace'

xcodeproj 'FPPicker.xcodeproj'
platform :ios, '7.1'

# We want AFNetworking to be shared between both targets.

pod 'AFNetworking', '~> 2.3.1'

# iOS Targets

target :'FPPicker', exclusive: true do
  platform :ios, '7.1'
  xcodeproj 'FPPicker.xcodeproj'
  pod 'MBProgressHUD', '~> 0.9'
end

target :'FPPicker Functional Tests', exclusive: true do
  platform :ios, '7.1'
  xcodeproj 'FPPicker.xcodeproj'
  pod 'OCMock', '~> 3.0.2'
  pod 'OHHTTPStubs', '~> 3.1.2'
end

target :'FPPicker Integration Tests', exclusive: true do
  platform :ios, '7.1'
  xcodeproj 'FPPicker.xcodeproj'
  pod 'OHHTTPStubs', '~> 3.1.2'
  pod 'Subliminal', '~> 1.1.0'
end

# Mac Targets

target :'FPPickerMac', exclusive: true do
  platform :osx, '10.9'
  link_with 'FPPickerMac'
  xcodeproj 'FPPicker Mac.xcodeproj'

#  pod 'AFNetworking', '~> 2.3.1'
end
