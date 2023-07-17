#!/bin/sh

# not enabling `errtrace` and `pipefail` since those are bash specific
set -o errexit # failing commands causes script to fail
set -o nounset # undefined variables causes script to fail

echo "src/gz packages_ci file:///ci" >> /etc/opkg/distfeeds.conf

FINGERPRINT="$(usign -F -p /ci/packages_ci.pub)"
cp /ci/packages_ci.pub "/etc/opkg/keys/$FINGERPRINT"

mkdir -p /var/lock/

opkg update

[ -n "${CI_HELPER:=''}" ] || CI_HELPER="/ci/.github/workflows/ci_helpers.sh"

for PKG in /ci/*.ipk; do
	tar -xzOf "$PKG" ./control.tar.gz | tar xzf - ./control
	# package name including variant
	PKG_NAME=$(sed -ne 's#^Package: \(.*\)$#\1#p' ./control)
	# package version without release
	PKG_VERSION=$(sed -ne 's#^Version: \(.*\)$#\1#p' ./control)
	PKG_VERSION="${PKG_VERSION%-[!-]*}"
	# package source containing test.sh script
	PKG_SOURCE=$(sed -ne 's#^Source: \(.*\)$#\1#p' ./control)
	PKG_SOURCE="${PKG_SOURCE#/feed/}"

	echo
	echo "Testing package $PKG_NAME in version $PKG_VERSION from $PKG_SOURCE"

	if ! [ -d "/ci/$PKG_SOURCE" ]; then
		echo "$PKG_SOURCE is not a directory"
		exit 1
	fi

	PRE_TEST_SCRIPT="/ci/$PKG_SOURCE/pre-test.sh"
	TEST_SCRIPT="/ci/$PKG_SOURCE/test.sh"

	if ! [ -f "$TEST_SCRIPT" ]; then
		echo "No test.sh script available"
		continue
	fi

	export PKG_NAME PKG_VERSION CI_HELPER

	if [ -f "$PRE_TEST_SCRIPT" ]; then
		echo "Use package specific pre-test.sh"
		if sh "$PRE_TEST_SCRIPT" "$PKG_NAME" "$PKG_VERSION"; then
			echo "Pre-test successful"
		else
			echo "Pre-test failed"
			exit 1
		fi
	else
		echo "No pre-test.sh script available"
	fi

	opkg install "$PKG"

	echo "Use package specific test.sh"
	if sh "$TEST_SCRIPT" "$PKG_NAME" "$PKG_VERSION"; then
		echo "Test successful"
	else
		echo "Test failed"
		exit 1
	fi

	opkg remove "$PKG_NAME" --force-removal-of-dependent-packages --force-remove --autoremove || true
done
