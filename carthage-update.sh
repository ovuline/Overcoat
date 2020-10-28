#!/usr/bin/env bash

# carthage-udpate.sh
# Usage example: ./carthage-update.sh --platform iOS --no-use-binaries <dependency names>
# Based on the script for working around a Carthage issue related to Xcode 12 posted here:
# https://github.com/Carthage/Carthage/issues/3019#issuecomment-665136323

set -euo pipefail

# Change directories to the script directory (which should be the ovia-ios directory).
SCRIPT_DIR=${0%/*}
if [[ "$0" != "$SCRIPT_DIR" ]] && [[ "$SCRIPT_DIR" != '' ]]; then
    cd $SCRIPT_DIR
fi
SCRIPT_DIR=$(pwd)

xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
trap 'rm -f "$xcconfig"' INT TERM HUP EXIT

# For Xcode 12 make sure EXCLUDED_ARCHS is set to arm architectures otherwise
# the build will fail on lipo due to duplicate architectures.
echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200 = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
echo 'EXCLUDED_ARCHS = $(inherited) $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_$(NATIVE_ARCH_64_BIT)__XCODE_$(XCODE_VERSION_MAJOR))' >> $xcconfig

export XCODE_XCCONFIG_FILE="$xcconfig"

carthage update "$@"
