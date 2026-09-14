#!/bin/sh

case "$1" in
snowflake-broker|\
snowflake-client|\
snowflake-probetest|\
snowflake-proxy|\
snowflake-server)
	# broker and probetest have no -version flag upstream, so this
	# checks that each binary runs and prints its usage rather than
	# matching a version/identity string
	"$1" -h 2>&1 | grep "Usage"
	;;
esac
