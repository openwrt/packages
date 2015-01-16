--[[

LuCI LXC module

Copyright (C) 2014, Cisco Systems, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Author: Petar Koretic <petar.koretic@sartura.hr>

]]--

module("luci.controller.lxc", package.seeall)

require "ubus"
local conn = ubus.connect()
if not conn then
    error("Failed to connect to ubus")
end


function fork_exec(command)
	local pid = nixio.fork()
	if pid > 0 then
		return
	elseif pid == 0 then
		-- change to root dir
		nixio.chdir("/")

		-- patch stdin, out, err to /dev/null
		local null = nixio.open("/dev/null", "w+")
		if null then
			nixio.dup(null, nixio.stderr)
			nixio.dup(null, nixio.stdout)
			nixio.dup(null, nixio.stdin)
			if null:fileno() > 2 then
				null:close()
			end
		end

		-- replace with target command
		nixio.exec("/bin/sh", "-c", command)
	end
end

function index()
	page = node("admin", "services", "lxc")
	page.target = cbi("lxc")
	page.title = _("LXC Containers")
	page.order = 70

	page = entry({"admin", "services", "lxc_create"}, call("lxc_create"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_action"}, call("lxc_action"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_configuration_get"}, call("lxc_configuration_get"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_configuration_set"}, call("lxc_configuration_set"), nil)
	page.leaf = true

end

function lxc_create(lxc_name, lxc_template)
	luci.http.prepare_content("text/plain")

	local uci = require("uci").cursor()

	local url = uci:get("lxc", "lxc", "url")

	if not pcall(dofile, "/etc/openwrt_release") then
		return luci.http.write("1")
	end

	local target = _G.DISTRIB_TARGET:match('([^/]+)')

	local data = conn:call("lxc", "create", { name = lxc_name, template = "download", args = { "--server", url,  "--no-validate", "--dist", lxc_template, "--release", "bb", "--arch", target } } )

	luci.http.write(data)
end

function lxc_action(lxc_action, lxc_name)
	luci.http.prepare_content("application/json")

	local data, ec = conn:call("lxc", lxc_action, lxc_name and { name = lxc_name} or {} )

	luci.http.write_json(ec and {} or data)
end

function lxc_configuration_get(lxc_name)
	luci.http.prepare_content("text/plain")

	local f = io.open("/lxc/" .. lxc_name .. "/config", "r")
	local content = f:read("*all")
	f:close()

	luci.http.write(content)
end

function lxc_configuration_set(lxc_name)
	luci.http.prepare_content("text/plain")

	local lxc_configuration = luci.http.formvalue("lxc_configuration")

	if lxc_configuration == nil then
		return luci.http.write("1")
	end

	local f, err = io.open("/lxc/" .. lxc_name .. "/config","w+")
	if not f then
		return luci.http.write("2")
	end

	f:write(lxc_configuration)
	f:close()

	luci.http.write("0")
end

