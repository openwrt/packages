#!/bin/sh

mkdir -p /var/lock/

opkg update

for PKG in /ci/*.ipk; do
	tar -xzOf "$PKG" ./control.tar.gz | tar xzf - ./control 
	# package name including variant
	PKG_NAME=$(sed -ne 's#^Package: \(.*\)$#\1#p' ./control)
	# package version without release
	PKG_VERSION=$(sed -ne 's#^Version: \(.*\)-[0-9]*$#\1#p' ./control)

	echo "Testing package $PKG_NAME ($PKG_VERSION)"

	opkg install "$PKG"

	TEST_SCRIPT=$(find /ci/ -name "$PKG_NAME" -type d)/test.sh
	if [ -f "$TEST_SCRIPT" ]; then
		echo "Use package specific test.sh"
		if sh "$TEST_SCRIPT" "$PKG_NAME" "$PKG_VERSION"; then
			echo "Test successfull"
		else
			echo "Test failed"
			exit 1
		fi
	else
		echo "No test.sh script available"
	fi

	opkg remove "$PKG_NAME" --force-removal-of-dependent-packages --force-remove
done
