workspace 'FPPicker.xcworkspace'

xcodeproj 'FPPicker.xcodeproj'
platform :ios, '7.1'

# iOS Targets

target :'FPPicker' do
  pod 'MBProgressHUD', '~> 0.9'
  pod 'AFNetworking', '~> 2.3.1'
end

target :'FPPicker Functional Tests' do
  pod 'OCMock', '~> 3.0.2'
  pod 'OHHTTPStubs', '~> 3.1.2'
end

target :'FPPicker Integration Tests' do
  pod 'OHHTTPStubs', '~> 3.1.2'
  pod 'Subliminal', '~> 1.1.0'
end

# Mac Targets

target :'FPPickerMac' do
  platform :osx, '10.9'
  link_with 'FPPickerMac'
  xcodeproj 'FPPicker Mac.xcodeproj'

  pod 'AFNetworking', '~> 2.3.1'
end
