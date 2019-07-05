--[[ 
Copyright (C) 2014-2017 - Eloi Carbo

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

require("luci.sys")
local http = require "luci.http"
local uci = luci.model.uci.cursor()

-- Repeated Strings
local common_string = "Valid options are:<br />" .. "1. all (All the routes)<br />" .. "2. none (No routes)<br />" .. "3. filter <b>Your_Filter_Name</b>      (Call a specific filter from any of the available in the filters files)"
local imp_string = "Set if the protocol must import routes.<br />" .. common_string
local exp_string = "Set if the protocol must export routes.<br />" .. common_string

m=Map("bird6", "Bird6 general protocol's configuration.")

-- Optional parameters lists
local protoptions = {
	{["name"]="table", ["help"]="Auxiliar table for routing", ["depends"]={"static","kernel"}},
	{["name"]="import", ["help"]=imp_string, ["depends"]={"kernel"}},
	{["name"]="export", ["help"]=exp_string, ["depends"]={"kernel"}},
	{["name"]="scan_time", ["help"]="Time between scans", ["depends"]={"kernel","device"}},
	{["name"]="kernel_table", ["help"]="Set which table must be used as auxiliar kernel table", ["depends"]={"kernel"}},
	{["name"]="learn", ["help"]="Learn routes", ["depends"]={"kernel"}},
	{["name"]="persist", ["help"]="Store routes. After a restart, routes willstill be configured", ["depends"]={"kernel"}}
}

local routeroptions = {
	{["name"]="prefix",["help"]="",["depends"]={"router","special","iface","multipath","recursive"}},
	{["name"]="via",["help"]="",["depends"]={"router","multipath"}},
	{["name"]="attribute",["help"]="",["depends"]={"special"}},
	{["name"]="iface",["help"]="",["depends"]={"iface"}},
	{["name"]="ip",["help"]="",["depends"]={"recursive"}}
}

--
-- KERNEL PROTOCOL
--

sect_kernel_protos = m:section(TypedSection, "kernel", "Kernel options", "Configuration of the kernel protocols. First Instance MUST be Primary table (no table or kernel_table fields).")
sect_kernel_protos.addremove = true
sect_kernel_protos.anonymous = false

-- Default kernel parameters

disabled = sect_kernel_protos:option(Flag, "disabled", "Disabled", "If this option is true, the protocol will not be configured.")
disabled.default=0

-- Optional parameters
for _,o in ipairs(protoptions) do
	if o.name ~= nil then
		for _, d in ipairs(o.depends) do
			if d == "kernel" then
				if o.name == "learn" or o.name == "persist" then
					value = sect_kernel_protos:option(Flag, o.name, translate(o.name), translate(o.help))
				elseif o.name == "table" then 
					value = sect_kernel_protos:option(ListValue, o.name, translate(o.name), translate(o.help))
					uci:foreach("bird6", "table",
						function (s)
							value:value(s.name)
						end)
					value:value("")
                    value.default = ""
				else
					value = sect_kernel_protos:option(Value, o.name, translate(o.name), translate(o.help))
				end
				value.optional = true
				value.rmempty = true
			end
		end

	end
end

--
-- DEVICE PROTOCOL
--

sect_device_protos = m:section(TypedSection, "device", "Device options", "Configuration of the device protocols.")
sect_device_protos.addremove = true
sect_device_protos.anonymous = false

-- Default kernel parameters

disabled = sect_device_protos:option(Flag, "disabled", "Disabled", "If this option is true, the protocol will not be configured.")
disabled.default=0

-- Optional parameters
for _,o in ipairs(protoptions) do
	if o.name ~= nil then
		for _, d in ipairs(o.depends) do
			if d == "device" then
				value = sect_device_protos:option(Value, o.name, translate(o.name), translate(o.help))
				value.optional = true
				value.rmempty = true
			end
		end
	end
end
																												
--
-- STATIC PROTOCOL
--

sect_static_protos = m:section(TypedSection, "static", "Static options", "Configuration of the static protocols.")
sect_static_protos.addremove = true
sect_static_protos.anonymous = false

-- Default kernel parameters

disabled = sect_static_protos:option(Flag, "disabled", "Disabled", "If this option is true, the protocol will not be configured.")
disabled.default=0

-- Optional parameters
for _,o in ipairs(protoptions) do
	if o.name ~= nil then
		for _, d in ipairs(o.depends) do
			if d == "static" then
				if o.name == "table" then
					value = sect_static_protos:option(ListValue, o.name, translate(o.name), translate(o.help))
					uci:foreach("bird6", "table",
						function (s)
							value:value(s.name)
						end)
					value:value("")
                    value.default = ""
				else
					value = sect_static_protos:option(Value, o.name, translate(o.name), translate(o.help))
				end
					value.optional = true
					value.rmempty = true
			end
		end
	end
end


--
-- PIPE PROTOCOL
--
sect_pipe_protos = m:section(TypedSection, "pipe", "Pipe options",     "Configuration of the Pipe protocols.")
sect_pipe_protos.addremove = true
sect_pipe_protos.anonymous = false

-- Default Pipe parameters
disabled = sect_pipe_protos:option(Flag, "disabled", "Disabled", "If this  option is true, the protocol will not be configured. This protocol will connect the configured 'Table' to the 'Peer Table'.")
disabled.default=0

table = sect_pipe_protos:option(ListValue, "table", "Table", "Select the Primary Table to connect.")
table.optional = false
uci:foreach("bird6", "table",
  function (s)
    table:value(s.name)
  end)
table:value("")
table.default = ""

peer_table = sect_pipe_protos:option(ListValue, "peer_table", "Peer Table", "Select the Secondary Table to connect.")
table.optional = false
uci:foreach("bird6", "table",
  function (s)
    peer_table:value(s.name)
  end)
peer_table:value("")
peer_table.default = ""

mode = sect_pipe_protos:option(ListValue, "mode", "Mode", "Select <b>transparent</b> to retransmit all routes and their attributes<br />Select <b>opaque</b> to retransmit optimal routes (similar to what other protocols do)")
mode.optional = false
mode:value("transparent")
mode:value("opaque")
mode.default = "transparent"

import = sect_pipe_protos:option(Value, "import", "Import",imp_string)
import.optional=true

export = sect_pipe_protos:option(Value, "export", "Export", exp_string)
export.optional=true


--
-- DIRECT PROTOCOL
--
sect_direct_protos = m:section(TypedSection, "direct", "Direct options", "Configuration of the Direct protocols.")
sect_direct_protos.addremove = true
sect_direct_protos.anonymous = false

-- Default Direct parameters
disabled = sect_direct_protos:option(Flag, "disabled", "Disabled", "If this option is true, the protocol will not be configured. This protocol will connect the configured 'Table' to the 'Peer Table'.")
disabled.optional = false
disabled.default = 0

interface = sect_direct_protos:option(Value, "interface", "Interfaces", "By default Direct will generate device routes for all the interfaces. To restrict this behaviour, select a number of patterns to match your desired interfaces:" .. "<br />" .. "1. All the strings <b>MUST</b> be quoted: \"pattern\"" .. "<br />" .. "2. Use * (star) to match patterns: \"eth*\" (<b>include</b> all eth... interfaces)" .. "<br />" .. "3. You can add \"-\" (minus) to exclude patterns: \"-em*\" (<b>exclude</b> all em... interfaces)." .. "<br />" .. "4. Separate several patterns using , (coma): \"-em*\", \"eth*\" (<b>exclude</b> em... and <b>include</b> all eth... interfaces).")
interface.optional = false
interface.default = "\"*\""


--
-- ROUTES FOR STATIC PROTOCOL
--
sect_routes = m:section(TypedSection, "route", "Routes configuration", "Configuration of the routes used in static protocols.")
sect_routes.addremove = true
sect_routes.anonymous = true

instance = sect_routes:option(ListValue, "instance", "Route instance", "")
i = 0

uci:foreach("bird6", "static",
	function (s)
		instance:value(s[".name"])
	end)

prefix = sect_routes:option(Value, "prefix", "Route prefix", "")
prefix.datatype = "ip6prefix"

type = sect_routes:option(ListValue, "type", "Type of route", "")
type:value("router")
type:value("special")
type:value("iface")
type:value("recursive")
type:value("multipath")

valueVia = sect_routes:option(Value, "via", "Via", "")
valueVia.optional = false
valueVia:depends("type", "router")
valueVia.datatype = "ip6addr"

listVia = sect_routes:option(DynamicList, "l_via", "Via", "")
listVia:depends("type", "multipath")
listVia.optional=false
listVia.datatype = "ip6addr"

attribute = sect_routes:option(Value, "attribute", "Attribute", "Types are: unreachable, prohibit and blackhole")
attribute:depends("type", "special")

iface  = sect_routes:option(ListValue, "iface", "Interface", "")
iface:depends("type", "iface")

uci:foreach("network", "interface",
	function(section)
        if section[".name"] ~= "loopback" then
            iface:value(section[".name"])
        end
	end)

ip =  sect_routes:option(Value, "ip", "IP address", "")
ip:depends("type", "ip")
ip.datatype = [[ or"ip4addr", "ip6addr" ]]

function m.on_commit(self,map)
        luci.sys.exec('/etc/init.d/bird6 restart')
end

return m

