#!/bin/sh

# shellcheck shell=busybox

case "$1" in
duperemove)
	# btrfs-extent-same has no --version/--help; it prints usage and
	# exits 1 when run without the required file/offset arguments.
	btrfs-extent-same 2>&1 | grep -F "Usage:" || exit 1

	# duperemove only scans a path whose filesystem it can identify: off
	# btrfs it rejects devices with major 0 (tmpfs, overlayfs) and
	# otherwise needs libblkid to find a UUID for the backing device.
	# The CI container's filesystem usually fails one of those, and the
	# path is then skipped silently (exit 0, nothing hashed). So the
	# scan is only checked end to end where the filesystem is
	# supported; elsewhere we require duperemove's own refusal message,
	# so a genuine scan regression still fails.
	#
	# Keep the hashfile outside the scanned directory so duperemove
	# does not pick up its own hashfile/WAL/SHM files as scan targets.
	# Both are absolute paths under the physical CWD (pwd -P), since
	# duperemove canonicalizes scanned paths with realpath() before
	# recording them and the lookup below must match that spelling. A CWD
	# of "/" would otherwise yield "//name", so strip the trailing slash.
	cwd="$(pwd -P)"
	cwd="${cwd%/}"
	dir="$(mktemp -d "$cwd/duperemove-test.XXXXXX")"
	hashfile="$(mktemp "$cwd/duperemove-test-hashes.XXXXXX")"
	trap 'rm -rf "$dir" "$hashfile" "$hashfile-wal" "$hashfile-shm"' EXIT

	# Two identical files give duperemove real duplicate extents to
	# hash, exercising the same code path (including the lscpu-based
	# core count detection) that a real scan would use.
	head -c 1048576 /dev/urandom > "$dir/a"
	cp "$dir/a" "$dir/b"

	# --debug is what makes duperemove explain why it skipped a path.
	out="$(duperemove -r --debug --hashfile="$hashfile" "$dir" 2>&1)" || {
		echo "$out"
		exit 1
	}
	[ -s "$hashfile" ] || exit 1

	if hashstats -l "$hashfile" 2>&1 | grep -F "$dir/a"; then
		exit 0
	fi

	if echo "$out" | grep -E 'unsupported filesystem|could not get uuid|unable to find the mount infos'; then
		echo "scan skipped: duperemove does not support this filesystem"
		exit 0
	fi

	echo "$out"
	exit 1
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
