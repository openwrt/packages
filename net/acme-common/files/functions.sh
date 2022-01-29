log() {
	prio="$1"
	shift
	if [ "$prio" != debug ] || [ "$debug" = 0 ]; then
		logger -t "$LOG_TAG" -s -p "daemon.$prio" -- "$@"
	fi
}
