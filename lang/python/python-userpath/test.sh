#!/bin/sh

[ "$1" = python3-userpath ] || exit 0

# Test version
userpath --version | grep -Fx "userpath, version $PKG_VERSION"

# Test append and prepend (changes take effect after shell restart,
# so only check that the commands succeed)
TEST_DIR="/tmp/userpath-test-$$"
userpath append "$TEST_DIR"

TEST_DIR2="/tmp/userpath-test2-$$"
userpath prepend "$TEST_DIR2"
