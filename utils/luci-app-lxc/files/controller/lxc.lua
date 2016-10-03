--[[

LuCI LXC module

Copyright (C) 2014, Cisco Systems, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Author: Petar Koretic <petar.koretic@sartura.hr>

]]--

-- TODO: Should start using hashes for the various property maps

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

	page = entry({"admin", "services", "lxc_get_templates"}, call("lxc_get_templates"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_get_downloadable"}, call("lxc_get_downloadable"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_configuration_get"}, call("lxc_configuration_get"), nil)
	page.leaf = true

	page = entry({"admin", "services", "lxc_configuration_set"}, call("lxc_configuration_set"), nil)
	page.leaf = true

end

function lxc_get_templates()
	luci.http.prepare_content("application/json")

	local f = io.popen('uname -m', 'r')
	local target = f:read('*a')
	f:close()
	target = target:gsub("^%s*(.-)%s*$", "%1")

	local templates = {}

	local f = fs.dir("/usr/share/lxc/templates")

	for template in f do
		local arch = target
		template = template:gsub("^.*lxc%-", "")

		if (template == "debian") or (template == "ubuntu") or (template == "ubuntu-cloud") then
			if target == "x86_64" then
				arch = "amd64"
			elseif (target == "i686") or (target == "i586") or
				(target == "i486") or (target == "i386") then
				arch = "i386"
			elseif target == "arm6vl" then
				arch = "armhf"
			end
		end
		templates[#templates + 1] = template .. ":" .. arch
	end

	luci.http.write_json(templates)
end

function lxc_get_downloadable()
	luci.http.prepare_content("application/json")

	local uci = require("uci").cursor()

	local url = uci:get("lxc", "lxc", "url")
	local validate = uci:get("lxc", "lxc", "check_signature", 0)
	local keyring = uci:get("lxc", "lxc", "keyring")

	local f = io.popen('uname -m', 'r')
	local target = f:read('*a')
	f:close()
	target = target:gsub("^%s*(.-)%s*$", "%1")

	local templates = {}
	local listargs = ""
	
	if validate and validate == "1" then
		if keyring and keyring ~= "" then
			listargs = "--keyring " .. keyring
		end
	else
		listargs = "--no-validate"
	end

	if url and url ~= "" then
		listargs = listargs .. " --server=" .. url
	end

	local f

	f = io.popen('lxc-create -n just_want_to_list_available_lxc_templates -t download -- ' .. listargs)

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
				templates[#templates + 1] = dist .. ":" .. version .. ":" .. arch .. ":" .. build:gsub(":","-")
			end
		end
	end
	f:close()
	luci.http.write_json(templates)
end

function lxc_create(lxc_name, lxc_template, lxc_parameters)
	luci.http.prepare_content("text/plain")

	local uci = require("uci").cursor()

	local data = "Failed to set create arguments"
	local validate = uci:get("lxc", "lxc", "check_signature", 0)
	local keyring = uci:get("lxc", "lxc", "keyring")

	if not pcall(dofile, "/etc/openwrt_release") then
		return luci.http.write("1")
	end

	local err = false

	createargs = { }

	local lxc_template_name

	if not lxc_template or lxc_template == "" then
		data = "Missing template specification"
		err = true
	else
		lxc_template_name = lxc_template:gsub("(.*):(.*)", '%1')
	end

	if not err then
		if not validate then
			if lxc_template_name == "download" or lxc_template_name == "openwrt" then
				createargs[#createargs + 1] = "--no-validate"
			end
        	else
			if keyring and keyring ~= "" then
				if lxc_template_name == "download" or lxc_template_name == "openwrt" then
					createargs[#createargs + 1] = "--keyring"
					createargs[#createargs + 1] = keyring
				elseif lxc_template_name == "ubuntu" or 
					lxc_template_name == "debian" or
					lxc_template_name == "cirros"	
				then
					createargs[#createargs + 1] = "--auth-key"
					createargs[#createargs + 1] = keyring
				end
			end
		end
	end

	if not err then
		if lxc_parameters == nil or lxc_parameters == "" then
			data = "Missing rootfs to use"
			err = true
		else
			local lxc_dist = lxc_parameters:gsub("(.*):(.*):(.*):.*", '%1')
			local lxc_release = lxc_parameters:gsub("(.*):(.*):(.*):.*", '%2')
			local lxc_arch = lxc_parameters:gsub("(.*):(.*):(.*):.*", '%3')
			local lxc_variant = lxc_parameters:gsub("(.*):(.*):(.*):(.*)", '%4')
			if lxc_dist == nil or lxc_release == nil or lxc_arch == nil then
				data = "Bad dist release or arch from " .. lxc_parameters
				err = true
			else
				if lxc_dist ~= "" then
					createargs[#createargs + 1] = "--dist"
					createargs[#createargs + 1] = lxc_dist
				end
				if lxc_release ~= "" then
					createargs[#createargs + 1] = "--release"
					createargs[#createargs + 1] = lxc_release
				end
				if lxc_arch ~= "" then
					createargs[#createargs + 1] = "--arch"
					createargs[#createargs + 1] = lxc_arch
				end
				if lxc_variant and lxc_variant ~= "" then
					createargs[#createargs + 1] = "--variant"
					createargs[#createargs + 1] = lxc_variant
				end
			end
		end
	end

	local url = uci:get("lxc", "lxc", "url")

	if not err and lxc_template_name and (lxc_template_name == "download" or lxc_template_name == "openwrt") then
		if url and url ~= "" then
			createargs[#createargs + 1] = "--server"
			createargs[#createargs + 1] = url
		end
	elseif not err then
		if url and url ~= "" then
			createargs[#createargs + 1] = "--mirror"
			createargs[#createargs + 1] = url
		end
	end

	if not err then
		data = conn:call("lxc", "create", { name = lxc_name, template = lxc_template_name, args = createargs } )
	end

	if not err and (not data or data == "") then
		data = "lxc-create -n " .. lxc_name .. " -t " .. lxc_template_name .. " -- "
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

