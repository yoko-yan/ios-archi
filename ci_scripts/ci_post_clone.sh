#!/bin/sh

# Xcode CloudでSwift MacrosとSPMプラグインのビルドエラーを回避
# https://zenn.dev/hmhv/articles/c7240daf96990a
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES

echo "$XCCONFIG" | base64 --decode > ../App/ios-archi/XCConfigs/Local.xcconfig
echo "$GOOGLE_SERVICE_INFO" | base64 --decode > ../App/ios-archi/Configs/GoogleService-Info-Release.plist
echo "$GOOGLE_SERVICE_INFO_DEBUG" | base64 --decode > ../App/ios-archi/Configs/GoogleService-Info-Debug.plist