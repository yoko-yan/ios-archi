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
      
      # FIXME: CocoaPods側で対応されたら修正
      # workaround for Xcode15 Beta
      # ref: https://github.com/CocoaPods/CocoaPods/issues/12012
      # Beta5 で対応されたようだが、再発しているのでワークアラウンドを追加
      xcconfig_path = config.base_configuration_reference.real_path
      xcconfig = File.read(xcconfig_path)
      xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
      File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
    end
  end
end
