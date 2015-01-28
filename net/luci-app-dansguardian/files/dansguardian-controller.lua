--[[

LuCI DansGuardian module

Copyright (C) 2015, Itus Networks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Author: Luka Perkov <luka@openwrt.org>

]]--

module("luci.controller.dansguardian", package.seeall)

function index()
	entry({"admin", "network", "dansguardian"}, cbi("dansguardian"), _("Dansguardian"))
end
