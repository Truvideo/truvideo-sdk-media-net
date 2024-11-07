xcodebuild archive -scheme "TruvideoMedia" -destination generic/platform=iOS -archivePath "archives/TruvideoMedia_iOS" -derivedDataPath "$PWD/derivedData" -clonedSourcePackagesDirPath "$HOME/Library/Developer/Xcode/DerivedData/$XCODE_SCHEME" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive -scheme "TruvideoMedia" -destination "generic/platform=iOS Simulator" -archivePath "archives/TruvideoMedia_iOS_Simulator" -derivedDataPath "$PWD/derivedData" -clonedSourcePackagesDirPath "$HOME/Library/Developer/Xcode/DerivedData/$XCODE_SCHEME" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework -framework archives/TruvideoMedia_iOS.xcarchive/Products/Library/Frameworks/TruvideoMedia.framework -framework archives/TruvideoMedia_iOS_Simulator.xcarchive/Products/Library/Frameworks/TruvideoMedia.framework -output TruvideoMedia.xcframework

