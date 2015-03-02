--[[

LuCI ITUS module

Copyright (C) 2015, Itus Networks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

Author: Luka Perkov <luka@openwrt.org>

]]--

local fs = require "nixio.fs"
local sys = require "luci.sys"
require "ubus"

m = Map("itus", translate("ITUS Settings"))
m.on_after_commit = function() luci.sys.call("if `grep -qs yes /etc/config/itus` ; then echo yes > /etc/itus/advanced.conf ; else echo no > /etc/itus/advanced.conf; fi") end

s = m:section(TypedSection, "itus")
s.anonymous = true
s.addremove = false

advanced = s:option(ListValue, "advanced", translate("Show advanced options"))
advanced:value("no","no")
advanced:value("yes","yes")
advanced.default="no"

return m
