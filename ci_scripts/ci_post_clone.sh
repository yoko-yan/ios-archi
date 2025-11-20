#!/bin/sh

make sourcery

echo "$XCCONFIG" | base64 --decode > ../App/ios-archi/XCConfigs/Local.xcconfig
echo "$GOOGLE_SERVICE_INFO" | base64 --decode > ../App/ios-archi/Configs/GoogleService-Info-Release.plist
echo "$GOOGLE_SERVICE_INFO_DEBUG" | base64 --decode > ../App/ios-archi/Configs/GoogleService-Info-Debug.plist