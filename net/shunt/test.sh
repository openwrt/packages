#!/bin/sh
# compile and load with the shipped ucode.
#

shunt 2>&1 | grep 'usage: shunt' || exit 1

ucode -e 'import * as a from "shunt.config"; import * as b from "shunt.nft";
	import * as c from "shunt.dns"; import * as d from "shunt.frame";
	import * as e from "shunt.match"; import * as f from "shunt.domain_file";
	import * as g from "shunt.route"; import * as h from "shunt.rt";
	print("modules-ok\n");' |
	grep 'modules-ok'
