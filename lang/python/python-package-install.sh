#!/bin/sh

log() {
	printf '%s\n' "$*"
}

error() {
	printf 'Error: %s\n' "$*" >&2
}

path_exists() {
	local dir="$1"
	local path="$2"

	[ -n "$(find "$dir"/$path -print -quit 2>/dev/null)" ]
}

file_dir_chmod() {
	local dir="$1"
	local path="$2"
	local file_mode="$3"
	local dir_mode="$4"
	shift; shift; shift; shift;

	if [ -n "$file_mode" ]; then
		find "$dir"/$path -type f "$@" -exec chmod "$file_mode" -- '{}' +
	fi

	if [ -n "$dir_mode" ]; then
		find "$dir"/$path -type d "$@" -exec chmod "$dir_mode" -- '{}' +
	fi
}

src="$1"
dest="$2"
filespec="$3"

if [ -z "$src" ]; then
	error "Missing source directory"
	exit 1
fi
if [ -z "$dest" ]; then
	error "Missing destination directory"
	exit 1
fi

while IFS='|' read -r cmd path file_mode dir_mode; do

	# trim whitespace

	cmd="${cmd#"${cmd%%[![:space:]]*}"}"
	cmd="${cmd%"${cmd##*[![:space:]]}"}"

	path="${path#"${path%%[![:space:]]*}"}"
	path="${path%"${path##*[![:space:]]}"}"

	file_mode="${file_mode#"${file_mode%%[![:space:]]*}"}"
	file_mode="${file_mode%"${file_mode##*[![:space:]]}"}"

	dir_mode="${dir_mode#"${dir_mode%%[![:space:]]*}"}"
	dir_mode="${dir_mode%"${dir_mode##*[![:space:]]}"}"


	if [ -z "$cmd" ] || [ "$cmd" != "${cmd#\#}" ]; then
		continue
	fi

	if [ -z "$path" ]; then
		error "Missing path for \"$cmd\""
		exit 1
	fi

	case "$cmd" in
	+)
		log "Copying: \"$path\""

		if ! path_exists "$src" "$path"; then
			error "\"$src/$path\" not found"
			exit 1
		fi

		dir="${path%/*}"
		mkdir -p "$dest/$dir"
		cp -fpR "$src"/$path "$dest/$dir/"

		file_dir_chmod "$dest" "$path" "$file_mode" "$dir_mode"
		;;

	-)
		log "Removing: \"$path\""

		if ! path_exists "$dest" "$path"; then
			error "\"$dest/$path\" not found"
			exit 1
		fi

		rm -fR -- "$dest"/$path
		;;

	=)
		log "Setting recursive permissions \"${file_mode:-(none)}\"/\"${dir_mode:-(none)}\" on \"$path\""

		if ! path_exists "$dest" "$path"; then
			error "\"$dest/$path\" not found"
			exit 1
		fi

		if [ -z "$file_mode$dir_mode" ]; then
			error "Missing recursive permissions for \"$path\""
			exit 1
		fi

		file_dir_chmod "$dest" "$path" "$file_mode" "$dir_mode"
		;;

	==)
		log "Setting permissions \"${file_mode:-(none)}\"/\"${dir_mode:-(none)}\" on \"$path\""

		if ! path_exists "$dest" "$path"; then
			error "\"$dest/$path\" not found"
			exit 1
		fi

		if [ -z "$file_mode$dir_mode" ]; then
			error "Missing permissions for \"$path\""
			exit 1
		fi

		file_dir_chmod "$dest" "$path" "$file_mode" "$dir_mode" -maxdepth 0
		;;

	*)
		error "Unknown command \"$cmd\""
		exit 1
		;;
	esac

done << EOF
$filespec
EOF
