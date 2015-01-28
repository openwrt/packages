--[[

LuCI Squid module

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

m = Map("squid", translate("Proxy"))
m.on_after_commit = function() luci.sys.call("/etc/init.d/squid restart") end

s = m:section(TypedSection, "squid")
s.anonymous = true
s.addremove = false

s:tab("general", translate("General Settings"))

local status="not running"
local conn = ubus.connect()
if not conn then
        error("Failed to connect to ubusd")
end

for k, v in pairs(conn:call("service", "list", { name="squid" })) do
        status="running"
end

button = s:taboption("general",Button, "start", translate("Status: "))
if status == "running" then
        button.inputtitle = "ON"
else
        button.inputtitle = "OFF"
end
button.write = function(self, section)
        if status == "not running" then
                sys.call("/etc/init.d/squid start >/dev/null")
		sys.call("/itus/squid.sh")
                button.inputtitle = "ON"
        else
                sys.call("/etc/init.d/squid stop >/dev/null")
		sys.call("/itus/squid.sh")
                button.inputtitle = "OFF"
        end
end

http_port = s:taboption("general", Value, "http_port", translate("Port"))
http_port.datatype = "portrange"
http_port.placeholder = "0-65535"

visible_hostname = s:taboption("general", Value, "visible_hostname", translate("Visible Hostname"))
visible_hostname.placeholder = "Shield"

io.input("/etc/itus/advanced.conf")
line = io.read("*line")

if line == "yes" then

	s:tab("advanced", translate("Advanced Settings"))

	squid_config_file = s:taboption("advanced", TextValue, "_data", "")
	squid_config_file.wrap = "off"
	squid_config_file.rows = 25
	squid_config_file.rmempty = false

	function squid_config_file.cfgvalue()
		local uci = require "luci.model.uci".cursor_state()
		local file = uci:get("squid", "squid", "config_file")
		if file then
			return fs.readfile(file) or ""
		else
			return ""
		end
	end

	function squid_config_file.write(self, section, value)
	    if value then
			local uci = require "luci.model.uci".cursor_state()
			local file = uci:get("squid", "squid", "config_file")
		fs.writefile(file, value:gsub("\r\n", "\n"))
	    end
	end

-- end of if statement
end

return m
