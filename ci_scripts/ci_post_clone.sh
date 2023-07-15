#!/bin/sh

# Install CocoaPods using Homebrew.
brew install cocoapods
		
# Install dependencies you manage with CocoaPods.
pod install


echo "$XCCONFIG" | base64 --decode > ../App/ios-archi/XCConfig/Local.xcconfig