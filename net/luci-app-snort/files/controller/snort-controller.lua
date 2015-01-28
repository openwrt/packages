--[[

LuCI Snort module

Copyright (C) 2015, Itus Networks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Author: Luka Perkov <luka@openwrt.org>

]]--

module("luci.controller.snort", package.seeall)

function index()
        page = node("admin", "services", "snort")
        page.target = cbi("snort")
        page.title = _("Intrusion Prevention")
        page.order = 70
end
