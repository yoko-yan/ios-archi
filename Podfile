# Uncomment the next line to define a global platform for your project
platform :ios, '16.0'
workspace 'ios-archi'
project 'App/ios-archi.xcodeproj'
install! 'cocoapods', :warn_for_unused_master_specs_repo => false

target 'ios-archi' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ios-archi
  pod 'SwiftLint'
  pod 'SwiftFormat/CLI'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
end
