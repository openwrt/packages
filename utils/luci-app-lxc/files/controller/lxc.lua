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

function index()
	page = node("admin", "services", "lxc")
	page.target = cbi("lxc")
	page.title = _("LXC Containers")
	page.order = 70

	page = entry({"admin", "services", "lxc_create"}, call("lxc_create"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_stop"}, call("lxc_stop"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_start"}, call("lxc_start"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_reboot"}, call("lxc_reboot"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_delete"}, call("lxc_delete"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_list"}, call("lxc_list"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_rename"}, call("lxc_rename"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_clone"}, call("lxc_clone"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_freeze"}, call("lxc_freeze"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_unfreeze"}, call("lxc_unfreeze"), nil)
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

	local f = io.popen([[grep DISTRIB_TARGET /etc/openwrt_release | awk -F"[/'']" '{ print $2 }']])
	if not f then
		return luci.http.write("1")
	end

	local target = f:read("*all")

	local res = os.execute("lxc-create -t download -n " .. lxc_name .. " -- --server=" .. url .. " --no-validate --dist openwrt --release bb --arch " .. target)

	luci.http.write(tostring(res))
end

function lxc_start(lxc_name)
	luci.http.prepare_content("text/plain")

	local res = os.execute("ubus call lxc start '{\"name\" : \"" .. lxc_name .. "\"}' ")

	luci.http.write(tostring(res))
end

function lxc_stop(lxc_name)
	luci.http.prepare_content("text/plain")

	local res = os.execute("ubus call lxc stop '{\"name\" : \"" .. lxc_name .. "\"}' ")

	luci.http.write(tostring(res))
end

function lxc_delete(lxc_name)
	luci.http.prepare_content("text/plain")

	os.execute("ubus call lxc stop '{\"name\" : \"" .. lxc_name .. "\"}' ")
	local res = os.execute("ubus call lxc destroy '{\"name\" : \"" .. lxc_name .. "\"}' ")

	luci.http.write(tostring(res))
end

function lxc_reboot(lxc_name)
	luci.http.prepare_content("text/plain")

	local res = os.execute("ubus call lxc reboot '{\"name\" : \"" .. lxc_name .. "\"}' ")

	luci.http.write(tostring(res))
end

function lxc_rename(lxc_name_cur, lxc_name_new)
	luci.http.prepare_content("text/plain")

	local res = os.execute("ubus call lxc rename '{\"name\" : \"" .. lxc_name_cur .. "\", \"newname\" : \"" .. lxc_name_new .. "\"}' ")

	luci.http.write(tostring(res))
end

function lxc_freeze(lxc_name)
	luci.http.prepare_content("text/plain")

	local res = os.execute("ubus call lxc freeze '{\"name\" : \"" .. lxc_name .. "\"}' ")

	luci.http.write(tostring(res))
end

function lxc_unfreeze(lxc_name)
	luci.http.prepare_content("text/plain")

	local res = os.execute("ubus call lxc unfreeze '{\"name\" : \"" .. lxc_name .. "\"}' ")

	luci.http.write(tostring(res))
end

function lxc_list()
	luci.http.prepare_content("application/json")

	local cmd = io.popen("ubus call lxc list")
	if not cmd then
		return luci.http.write("{}")
	end

	local res = cmd:read("*all")
	cmd:close()

	luci.http.write(res)
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

