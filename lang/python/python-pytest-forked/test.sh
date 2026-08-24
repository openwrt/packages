#!/bin/sh

[ "$1" = python3-pytest-forked ] || exit 0

# The plugin must register its --forked option with the installed pytest,
# which proves both the plugin and its pytest dependency import cleanly.
if ! python3 -m pytest --help 2>&1 | grep -- "--forked"; then
	echo "FAIL: pytest-forked did not register the --forked option"
	exit 1
fi
