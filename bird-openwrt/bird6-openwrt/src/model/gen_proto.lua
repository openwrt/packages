--[[ 
Copyright (C) 2014 - Eloi Carbó Solé (GSoC2014) 
BGP/Bird integration with OpenWRT and QMP

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
local uci = require "luci.model.uci"
local uciout = uci.cursor()

m=Map("bird6", "Bird6 general protocol's configuration.")

-- Optional parameters lists
local protoptions = {
	{["name"]="table", ["help"]="Auxiliar table for routing", ["depends"]={"static","kernel"}},
	{["name"]="import", ["help"]="Set if the protocol must import routes", ["depends"]={"kernel"}},
	{["name"]="export", ["help"]="Set if the protocol must export routes", ["depends"]={"kernel"}},
	{["name"]="scan_time", ["help"]="Time between scans", ["depends"]={"kernel","device"}},
	{["name"]="kernel_table", ["help"]="Set which table must be used as auxiliar kernel table", ["depends"]={"kernel"}},
	{["name"]="learn", ["help"]="Learn routes", ["depends"]={"kernel"}},
	{["name"]="persist", ["help"]="Store routes. After a restart, routes will be still configured", ["depends"]={"kernel"}}
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
					uciout:foreach("bird6", "table",
						function (s)
							value:value(s.name)
						end)
					value:value("")
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
					uciout:foreach("bird6", "table",
						function (s)
							value:value(s.name)
						end)
					value:value("")
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
-- ROUTES FOR STATIC PROTOCOL
--


sect_routes = m:section(TypedSection, "route", "Routes configuration", "Configuration of the routes used in static protocols.")
sect_routes.addremove = true
sect_routes.anonymous = true

instance = sect_routes:option(ListValue, "instance", "Route instance", "")
i = 0

uciout:foreach("bird6", "static",
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

uciout:foreach("wireless", "wifi-iface",
	function(section)
		iface:value(section[".name"])
	end)

ip =  sect_routes:option(Value, "ip", "IP address", "")
ip:depends("type", "ip")
ip.datatype = [[ or"ip4addr", "ip6addr" ]]

function m.on_commit(self,map)
        luci.sys.call('/etc/init.d/bird6 stop; /etc/init.d/bird6 start')
end

return m

