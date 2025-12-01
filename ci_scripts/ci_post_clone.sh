#!/bin/sh

# Xcode CloudでSwift MacrosとSPMプラグインのビルドエラーを回避
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidation -bool YES

# swift-syntaxのプリビルトバイナリを使用せずソースからビルドする
export SWIFT_PACKAGE_USE_PREBUILT_ONLY=NO

echo "$XCCONFIG" | base64 --decode > ../App/ios-archi/XCConfigs/Local.xcconfig
echo "$GOOGLE_SERVICE_INFO" | base64 --decode > ../App/ios-archi/Configs/GoogleService-Info-Release.plist
echo "$GOOGLE_SERVICE_INFO_DEBUG" | base64 --decode > ../App/ios-archi/Configs/GoogleService-Info-Debug.plist