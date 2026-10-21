#!/bin/sh
# compile and load with the shipped ucode.
#

travelmate 2>&1 | grep 'usage: travelmate' || exit 1

ucode -e 'import * as a from "travelmate.daemon"; import * as b from "travelmate.login";
	print("modules-ok\n");' |
	grep 'modules-ok'
