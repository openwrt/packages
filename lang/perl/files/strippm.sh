#!/bin/sh
# 
# Attempt to strip comments and pod docs from perl modules
#

[ "$#" -gt 0 ] || set .
echo "---> Stripping modules in: $@" >&2
find "$@" -name \*.pm -or -name \*.pl -or -name \*.pod | while read fn; do
	echo "   $fn" >&2
	sed -i -e '/^=\(head\|pod\|item\|over\|back\)/,/^=cut/d; /^=\(head\|pod\|item\|over\|back\)/,$d; /^#$/d; /^#[^!"'"'"']/d' "$fn"
done
