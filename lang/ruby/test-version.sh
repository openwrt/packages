#!/bin/sh

PKG_NAME="$1"
PKG_VERSION="$2"

# Only perform the version check for the main 'ruby' package.
# This prevents errors where subpackages (like gems) have their own 
# internal versions (e.g., rbs 3.10.0) that don't match the main package version.
if [ "$PKG_NAME" = "ruby" ]; then
    # Execute the ruby binary and check if the expected version string
    # is present in its standard output or standard error.
    if ruby --version 2>&1 | grep -q "$PKG_VERSION"; then
        echo "Version check passed for $PKG_NAME ($PKG_VERSION)"
        exit 0
    else
        echo "Version check failed for $PKG_NAME. Expected version: $PKG_VERSION"
        exit 1
    fi
fi

# For all other subpackages (ruby-rbs, ruby-json, etc.), skip the check
# and return success to bypass the generic version test.
echo "Skipping version check for subpackage: $PKG_NAME"
exit 0
