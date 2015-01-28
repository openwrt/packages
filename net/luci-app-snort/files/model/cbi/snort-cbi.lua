--[[

LuCI Snort module

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

m = Map("snort", translate("Intrusion Prevention"))
m.on_after_commit = function() luci.sys.call("/etc/init.d/snort restart") end
m.reset = false
m.submit = false

s = m:section(NamedSection, "snort")
s.anonymous = true
s.addremove = false

s:tab("tab_basic", translate("Basic Settings"))
s:tab("tab_advanced", translate("Advanced Settings"))
s:tab("tab_engine", translate("Engine"))
s:tab("tab_preprocessors", translate("Preprocessors"))
s:tab("tab_other", translate("Other Settings"))
s:tab("tab_rules", translate("Rules"))
-- s:tab("tab_logs", translate("Logs"))


--------------------- Basic Tab ------------------------

local status="not running"
require "ubus"
local conn = ubus.connect()
if not conn then
        error("Failed to connect to ubusd")
end

for k, v in pairs(conn:call("service", "list", { name="snort" })) do
        status="running"
end

button = s:taboption("tab_basic",Button, "start", translate("Status: "))
if status == "running" then
        button.inputtitle = "ON"
else
        button.inputtitle = "OFF"
end
button.write = function(self, section)
        if status == "not running" then
                sys.call("/etc/init.d/snort start >/dev/null")
                button.inputtitle = "ON"
                button.title = "Status: "
        else
                sys.call("/etc/init.d/snort stop >/dev/null")
                button.inputtitle = "OFF"
                button.title = "Status: "
        end
end

--------------------- Advanced Tab -----------------------

io.input("/etc/itus/advanced.conf")
line = io.read("*line")

if line == "yes" then

	config_file1 = s:taboption("tab_advanced", TextValue, "text1", "")
	config_file1.wrap = "off"
	config_file1.rows = 25
	config_file1.rmempty = false

	function config_file1.cfgvalue()
		local uci = require "luci.model.uci".cursor_state()
		file = "/etc/snort/config1_advanced.conf"
		if file then
			return fs.readfile(file) or ""
		else
			return ""
		end
	end

	function config_file1.write(self, section, value)
		if value then
			local uci = require "luci.model.uci".cursor_state()
			file = "/etc/snort/config1_advanced.conf"
			fs.writefile(file, value:gsub("\r\n", "\n"))
		end
	end

	---------------------- Engine Tab ------------------------

	config_file2 = s:taboption("tab_engine", TextValue, "text2", "")
	config_file2.wrap = "off"
	config_file2.rows = 25
	config_file2.rmempty = false

	function config_file2.cfgvalue()
		local uci = require "luci.model.uci".cursor_state()
		file = "/etc/snort/config2_engine.conf"
		if file then
			return fs.readfile(file) or ""
		else
			return ""
		end
	end

	function config_file2.write(self, section, value)
		if value then
			local uci = require "luci.model.uci".cursor_state()
			file = "/etc/snort/config2_engine.conf"
			fs.writefile(file, value:gsub("\r\n", "\n"))
		end
	end

	------------------- Preprocessors Tab ---------------------

	config_file3 = s:taboption("tab_preprocessors", TextValue, "text3", "")
	config_file3.wrap = "off"
	config_file3.rows = 25
	config_file3.rmempty = false

	function config_file3.cfgvalue()
		local uci = require "luci.model.uci".cursor_state()
		file = "/etc/snort/config3_preprocessors.conf"
		if file then
			return fs.readfile(file) or ""
		else
			return ""
		end
	end

	function config_file3.write(self, section, value)
		if value then
			local uci = require "luci.model.uci".cursor_state()
			file = "/etc/snort/config3_preprocessors.conf"
			fs.writefile(file, value:gsub("\r\n", "\n"))
		end
	end

	--------------------- Other Tab ------------------------

	config_file4 = s:taboption("tab_other", TextValue, "text4", "")
	config_file4.wrap = "off"
	config_file4.rows = 25
	config_file4.rmempty = false

	function config_file4.cfgvalue()
		local uci = require "luci.model.uci".cursor_state()
		file = "/etc/snort/config4_other.conf"
		if file then
			return fs.readfile(file) or ""
		else
			return ""
		end
	end

	function config_file4.write(self, section, value)
		if value then
			local uci = require "luci.model.uci".cursor_state()
			file = "/etc/snort/config4_other.conf"
			fs.writefile(file, value:gsub("\r\n", "\n"))
		end
	end

	--------------------- Rules Tab ------------------------

-- End of if statement
end

config_file5 = s:taboption("tab_rules", TextValue, "text5", "")
config_file5.wrap = "off"
config_file5.rows = 25
config_file5.rmempty = false

function config_file5.cfgvalue()
        local uci = require "luci.model.uci".cursor_state()
        file = "/etc/snort/config5_rules.conf"
        if file then
                return fs.readfile(file) or ""
        else
                return ""
        end
end

function config_file5.write(self, section, value)
        if value then
                local uci = require "luci.model.uci".cursor_state()
                file = "/etc/snort/config5_rules.conf"
                fs.writefile(file, value:gsub("\r\n", "\n"))
        end
end

--------------------- Logs Tab ------------------------
-- placeholder6 = s:taboption("tab_logs", DummyValue, "placeholder6", translate("Placeholder DummyValue"))

return m
