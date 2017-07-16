#!/bin/sh
#
# MIT Alexander Couzens <lynxis@fe80.eu>

set -e

SDK_HOME="$HOME/sdk"
SDK_PATH=https://downloads.lede-project.org/snapshots/targets/ar71xx/generic/
SDK=lede-sdk-ar71xx-generic_gcc-5.4.0_musl.Linux-x86_64
PACKAGES_DIR="$PWD"

# download will run on the `before_script` step
# The travis cache will be used (all files under $HOME/sdk/). Meaning
# We don't have to download the file again
download_sdk() {
	mkdir -p "$SDK_HOME"
	cd "$SDK_HOME"

	echo "=== download SDK"
	wget "$SDK_PATH/sha256sums" -O sha256sums
	wget "$SDK_PATH/sha256sums.gpg" -O sha256sums.asc

	# LEDE Build System (LEDE GnuPG key for unattended build jobs)
	gpg --recv 0xCD84BCED626471F1
	# LEDE Release Builder (17.01 "Reboot" Signing Key)
	gpg --recv 0x833C6010D52BBB6B
	gpg --verify sha256sums.asc
	grep "$SDK" sha256sums > sha256sums.small

	# if missing, outdated or invalid, download again
	if ! sha256sum -c ./sha256sums.small ; then
		wget "$SDK_PATH/$SDK.tar.xz" -O "$SDK.tar.xz"
	fi

	# check again and fail here if the file is still bad
	sha256sum -c ./sha256sums.small
	echo "=== SDK is up-to-date"
}

# test_package will run on the `script` step.
# test_package call make download check for very new/modified package in it's
# own clean sdk directory
test_packages() {
	# search for new or modified packages. PKGS will hold a list of package like 'admin/muninlite admin/monit ...'
	PKGS=$(git diff --stat "$TRAVIS_COMMIT_RANGE" | grep Makefile | grep -v '/files/' | awk '{ print $1}' | awk -F'/Makefile' '{ print $1 }')

	if [ -z "$PKGS" ] ; then
		echo "No new or modified packages found!" >&2
		exit 0
	fi

	echo "=== Found new/modified packages:"
	for pkg in $PKGS ; do
		echo "===+ $pkg"
	done

	# E.g: pkg_dir => admin/muninlite
	#      pkg_name => muninlite
	for pkg_dir in $PKGS ; do
		pkg_name=$(echo "$pkg_dir" | awk -F/ '{ print $NF }')
		tmp_path=$HOME/tmp/$pkg_name/

		echo "=== $pkg_name Testing package"

		# create a clean sdk for every package
		mkdir -p "$tmp_path"
		cd "$tmp_path"
		tar Jxf "$SDK_HOME/$SDK.tar.xz"
		cd "$SDK"

		cat > feeds.conf <<EOF
src-git base https://git.lede-project.org/source.git
src-link packages $PACKAGES_DIR
src-git luci https://git.lede-project.org/project/luci.git
src-git routing https://git.lede-project.org/feed/routing.git
src-git telephony https://git.lede-project.org/feed/telephony.git
EOF
		./scripts/feeds update 2>/dev/null >/dev/null
		./scripts/feeds install "$pkg_name"

		make defconfig
		make "package/$pkg_name/download" V=s
		make "package/$pkg_name/check" V=s | tee -a logoutput
		grep WARNING logoutput && exit 1
		rm -rf "$tmp_path"
		echo "=== $pkg_name Finished package"
	done
}

export

if [ "$TRAVIS_PULL_REQUEST" = false ] ; then
	echo "Only Pull Requests are supported at the moment." >&2
	exit 0
fi


if [ $# -ne 1 ] ; then
	cat <<EOF
Usage: $0 (download_sdk|test_packages)

download_sdk - download the SDK to $HOME/sdk.tar.xz
test_packages - do a make check on the package
EOF
	exit 1
fi

$@
