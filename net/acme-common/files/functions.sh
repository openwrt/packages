log() {
	prio="$1"
	shift
	if [ "$prio" != debug ] || [ "$debug" = 1 ]; then
		logger -t "$LOG_TAG" -p "daemon.$prio" -- "$@"
	fi
}
