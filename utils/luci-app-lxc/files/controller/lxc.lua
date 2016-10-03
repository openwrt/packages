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

local fs = require("nixio.fs")

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

	page = entry({"admin", "services", "lxc_get_downloadable"}, call("lxc_get_downloadable"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_configuration_get"}, call("lxc_configuration_get"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_configuration_set"}, call("lxc_configuration_set"), nil)
	page.leaf = true

end

function lxc_get_downloadable()
	luci.http.prepare_content("application/json")

	local uci = require("uci").cursor()

	local url = uci:get("lxc", "lxc", "url")

	local f = io.popen('uname -m', 'r')
	local target = f:read('*a')
	f:close()
	target = target:gsub("^%s*(.-)%s*$", "%1")

	local templates = {}

	local f

	if url and url ~= "" then
		f = io.popen('lxc-create -n just_want_to_list_available_lxc_templates -t download -- --server=' .. url .. ' --list', 'r')
	else
		f = io.popen('lxc-create -n just_want_to_list_available_lxc_templates -t download -- --list', 'r')
	end

	for line in f:lines() do
		local dist,version,arch,build = line:match("^(%S+)%s+(%S+)%s(%S+)%s+default%s+(%S+)$")
		if dist ~= nil and version ~= nil and arch ~= nil and build ~= nil then
			if ((target == arch) or ((dist ~= "openwrt" and dist ~= "lede")) and
				(target == "x86_64" and arch == "amd64") or
				(target == "i686" and arch == "i386") or
				(target == "i586" and arch == "i386") or
				(target == "i486" and arch == "i386") or
				(target == "arm6vl" and arch == "armhf")
			) then
				templates[#templates + 1] = dist .. ":" .. version .. ":" .. arch .. ":" .. build.replace(":","-")
			end
		end
	end
	f:close()
	luci.http.write_json(templates)
end

function lxc_create(lxc_name, lxc_template)
	luci.http.prepare_content("text/plain")

	local uci = require("uci").cursor()

	local url = uci:get("lxc", "lxc", "url")

	local data = "Failed to set create arguments"
	local validate = uci:get("lxc", "lxc", "check_signature", 0)
	local keyring = uci:get("lxc", "lxc", "keyring")

	if not pcall(dofile, "/etc/openwrt_release") then
		return luci.http.write("1")
	end

	local err = false

	createargs = { }

	if not validate then
		createargs[#createargs + 1] = "--no-validate"
        else
		if keyring and keyring ~= "" then
			createargs[#createargs + 1] = "--keyring"
			createargs[#createargs + 1] = keyring
		end
	end

	if lxc_template == nil or lxc_template == "" then
		data = "Missing image selection"
		err = true
	end

	if not err then
		if lxc_template == nil or lxc_template == "" then
			data = "Missing image to use"
			createargs = { }
		else
			local lxc_dist = lxc_template:gsub("(.*):(.*):(.*):.*", '%1')
			local lxc_release = lxc_template:gsub("(.*):(.*):(.*):.*", '%2')
			local lxc_arch = lxc_template:gsub("(.*):(.*):(.*):.*", '%3')
			if lxc_dist == nil or lxc_dist == "" or lxc_release == nil or lxc_release == "" or
				lxc_arch == nil or lxc_arch == ""
			then
				data = "Bad dist release or arch from " .. lxc_template
				err = true
			else
				if url and url ~= "" then
					createargs[#createargs + 1] = "--server"
					createargs[#createargs + 1] = url
				end
				createargs[#createargs + 1] = "--dist"
				createargs[#createargs + 1] = lxc_dist
				createargs[#createargs + 1] = "--release"
				createargs[#createargs + 1] = lxc_release
				createargs[#createargs + 1] = "--arch"
				createargs[#createargs + 1] = lxc_arch
			end
		end
	end

	if not err then
		data = conn:call("lxc", "create", { name = lxc_name, template = "download", args = createargs } )
	end

	if not data or data == "" then
		data = "lxc-create -n " .. lxc_name .. "-t download -- "
		for k, v in ipairs(createargs) do
			data = data .. v .. " "
		end
	end

	luci.http.write(luci.util.pcdata(data))
end

function lxc_action(lxc_action, lxc_name)
	luci.http.prepare_content("application/json")

	local data, ec = conn:call("lxc", lxc_action, lxc_name and { name = lxc_name} or {} )

	luci.http.write_json(ec and {} or data)
end

function lxc_get_config_path()
	local f = io.open("/etc/lxc/lxc.conf", "r")
	local content = f:read("*all")
	f:close()
	local ret = content:match('^%s*lxc.lxcpath%s*=%s*([^%s]*)')
	if ret then
		return ret .. "/"
	else
		return "/srv/lxc/"
	end
end

function lxc_configuration_get(lxc_name)
	luci.http.prepare_content("text/plain")

	local f = io.open(lxc_get_config_path() .. lxc_name .. "/config", "r")
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

	local f, err = io.open(lxc_get_config_path() .. lxc_name .. "/config","w+")
	if not f then
		return luci.http.write("2")
	end

	f:write(lxc_configuration)
	f:close()

	luci.http.write("0")
end

