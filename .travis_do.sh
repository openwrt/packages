#!/bin/bash
#
# MIT Alexander Couzens <lynxis@fe80.eu>

set -e

SDK_HOME="$HOME/sdk"
SDK_PATH=https://downloads.lede-project.org/snapshots/targets/ar71xx/generic/
SDK=lede-sdk-ar71xx-generic_gcc-5.4.0_musl.Linux-x86_64
PACKAGES_DIR="$PWD"

echo_red()   { printf "\033[1;31m$*\033[m\n"; }
echo_green() { printf "\033[1;32m$*\033[m\n"; }
echo_blue()  { printf "\033[1;34m$*\033[m\n"; }

exec_status() {
	("$@" 2>&1) > logoutput && status=0 || status=1
	grep -qE 'WARNING|ERROR' logoutput && status=1
	cat logoutput
	if [ $status -eq 0 ]; then
		echo_green "=> $* successful"
		return 0
	else
		echo_red   "=> $* failed"
		return 1
	fi
}

# download will run on the `before_script` step
# The travis cache will be used (all files under $HOME/sdk/). Meaning
# We don't have to download the file again
download_sdk() {
	mkdir -p "$SDK_HOME"
	cd "$SDK_HOME"

	echo_blue "=== download SDK"
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
	echo_blue "=== SDK is up-to-date"
}

# test_package will run on the `script` step.
# test_package call make download check for very new/modified package in it's
# own clean sdk directory
test_packages() {
	# search for new or modified packages. PKGS will hold a list of package like 'admin/muninlite admin/monit ...'
	PKGS=$(git diff --name-only "$TRAVIS_COMMIT_RANGE" | grep 'Makefile$' | grep -v '/files/' | awk -F'/Makefile' '{ print $1 }')

	if [ -z "$PKGS" ] ; then
		echo_blue "No new or modified packages found!" >&2
		exit 0
	fi

	echo_blue "=== Found new/modified packages:"
	for pkg in $PKGS ; do
		echo "===+ $pkg"
	done

	echo_blue "=== Setting up SDK"
	tmp_path=$(mktemp -d)
	cd "$tmp_path"
	tar Jxf "$SDK_HOME/$SDK.tar.xz" --strip=1

	# use github mirrors to spare lede servers
	cat > feeds.conf <<EOF
src-git base https://github.com/lede-project/source.git
src-link packages $PACKAGES_DIR
src-git luci https://github.com/openwrt/luci.git
EOF

	./scripts/feeds update -a
	./scripts/feeds install -a
	make defconfig
	echo_blue "=== Setting up SDK done"

	RET=0
	# E.g: pkg_dir => admin/muninlite
	# pkg_name => muninlite
	for pkg_dir in $PKGS ; do
		pkg_name=$(echo "$pkg_dir" | awk -F/ '{ print $NF }')
		echo_blue "=== $pkg_name Testing package"

		exec_status make "package/$pkg_name/download" V=s || RET=1
		exec_status make "package/$pkg_name/check" V=s || RET=1

		echo_blue "=== $pkg_name Finished package"
	done

	exit $RET
}

test_commits() {
	RET=0
	for commit in $(git rev-list ${TRAVIS_COMMIT_RANGE/.../..}); do
		echo_blue "=== Checking commit '$commit'"
		if git show --format='%P' -s $commit | grep -qF ' '; then
			echo_red "Pull request should not include merge commits"
			RET=1
		fi

		author="$(git show -s --format=%aN $commit)"
		if echo $author | grep -q '\S\+\s\+\S\+'; then
			echo_green "Author name ($author) seems ok"
		else
			echo_red "Author name ($author) need to be your real name 'firstname lastname'"
			RET=1
		fi

		subject="$(git show -s --format=%s $commit)"
		if echo "$subject" | grep -q '^[0-9A-Za-z,]\+: '; then
			echo_green "Commit subject line seems ok ($subject)"
		else
			echo_red "Commit subject line MUST start with '<package name>: ' ($subject)"
			RET=1
		fi

		body="$(git show -s --format=%b $commit)"
		sob="$(git show -s --format='Signed-off-by: %aN <%aE>' $commit)"
		if echo "$body" | grep -qF "$sob"; then
			echo_green "Signed-off-by match author"
		else
			echo_red "Signed-off-by is missing or doesn't match author (should be '$sob')"
			RET=1
		fi
	done

	exit $RET
}

echo_blue "=== Travis ENV"
env
echo_blue "=== Travis ENV"

until git merge-base ${TRAVIS_COMMIT_RANGE/.../ } > /dev/null; do
	echo_blue "Fetching 50 commits more"
	git fetch origin --deepen=50
done

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
