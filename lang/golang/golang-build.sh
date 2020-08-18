#!/bin/sh

log() {
	# shellcheck disable=SC2039
	local IFS=" "
	printf '%s\n' "$*"
}

log_error() {
	# shellcheck disable=SC2039
	local IFS=" "
	printf 'Error: %s\n' "$*" >&2
}

cache_cleanup() {
	if ! [ -d "$GO_MOD_CACHE_DIR" ]; then
		return 0
	fi

	# in case go is called without -modcacherw
	find "$GO_MOD_CACHE_DIR" -type d -not -perm -u+w -exec chmod u+w '{}' +

	if [ -n "$CONFIG_GOLANG_MOD_CACHE_WORLD_READABLE" ]; then
		find "$GO_MOD_CACHE_DIR"      -type d -not -perm -go+rx -exec chmod go+rx '{}' +
		find "$GO_MOD_CACHE_DIR" -not -type d -not -perm -go+r  -exec chmod go+r  '{}' +
	fi

	return 0
}


if [ "$#" -lt 1 ]; then
	log_error "Missing command"
	exit 1
fi

command="$1"
shift 1

case "$command" in
	cache_cleanup)
		cache_cleanup
		;;
	*)
		log_error "Invalid command \"$command\""
		exit 1
		;;
esac
