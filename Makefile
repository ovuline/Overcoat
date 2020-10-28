XC_WORKSPACE=Overcoat.xcworkspace
XCODE_PROJ=Overcoat.xcodeproj

OSX_TEST_SCHEME_FLAGS:=-workspace $(XC_WORKSPACE) -scheme OvercoatTests-OSX -sdk macosx
IOS_TEST_SCHEME_FLAGS:=-workspace $(XC_WORKSPACE) -scheme OvercoatTests-iOS -sdk iphonesimulator
IOS_TEST_DESTINATION:=-destination 'platform=iOS Simulator,name=iPhone 7,OS=10.0'
TVOS_TEST_SCHEME_FLAGS:=-workspace $(XC_WORKSPACE) -scheme OvercoatTests-tvOS -sdk appletvsimulator
TVOS_TEST_DESTINATION:=-destination 'platform=tvOS Simulator,name=Apple TV 1080p,OS=10.0'

CARTHAGE_PLATFORMS=Mac,iOS
CARTHAGE_FLAGS:=--platform $(CARTHAGE_PLATFORMS)

POD_TRUNK_PUSH_FLAGS=--verbose

test: install-pod clean run-tests

test-osx: install-pod clean run-tests-osx

test-ios: install-pod clean run-tests-ios

test-tvos: install-pod clean run-tests-tvos

clean:
	xcodebuild -project $(XCODE_PROJ) -alltargets clean

install-pod:
	COCOAPODS_DISABLE_DETERMINISTIC_UUIDS=YES pod install --repo-update

# Run Tests

run-tests-osx:
	xcodebuild $(OSX_TEST_SCHEME_FLAGS) test | xcpretty

run-tests-ios:
	xcodebuild $(IOS_TEST_SCHEME_FLAGS) $(IOS_TEST_DESTINATION) test | xcpretty

run-tests-tvos:
	xcodebuild $(TVOS_TEST_SCHEME_FLAGS) $(TVOS_TEST_DESTINATION) test | xcpretty

# Intetfaces

run-tests: run-tests-osx run-tests-ios run-tests-tvos

# Distribution

test-carthage:
	rm -rf Pods/
	carthage update $(CARTHAGE_FLAGS)
	carthage build --no-skip-current $(CARTHAGE_FLAGS) --verbose

test-pod:
	pod spec lint ./*.podspec --verbose --allow-warnings --no-clean --fail-fast

distribute-pod: test
	pod trunk push Overcoat.podspec $(POD_TRUNK_PUSH_FLAGS)
	pod trunk push Overcoat+CoreData.podspec --allow-warnings $(POD_TRUNK_PUSH_FLAGS)
	pod trunk push Overcoat+PromiseKit.podspec $(POD_TRUNK_PUSH_FLAGS)
	pod trunk push Overcoat+ReactiveCocoa.podspec $(POD_TRUNK_PUSH_FLAGS)
	pod trunk push Overcoat+Social.podspec $(POD_TRUNK_PUSH_FLAGS)

distribute-carthage: test
