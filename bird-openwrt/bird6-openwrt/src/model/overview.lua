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
]]--

require("luci.sys")
local http = require "luci.http"
local uci = require "luci.model.uci"
local uciout = uci.cursor()

m=Map("bird6", "Bird6 UCI configuration helper", "")

-- Named section: "bird"

s_bird_uci = m:section(NamedSection, "bird", "bird", "Bird6 file settings", "")
s_bird_uci.addremove = False

uuc = s_bird_uci:option(Flag, "use_UCI_config", "Use UCI configuration", "Use UCI configuration instead of the /etc/bird6.conf file")

ucf = s_bird_uci:option(Value, "UCI_config_File", "UCI File", "Specify the file to place the UCI-translated configuration")
ucf.default = "/tmp/bird6.conf"

-- Named Section: "table"

s_bird_table = m:section(TypedSection, "table", "Tables configuration", "Configuration of the tables used in the protocols")
s_bird_table.addremove = true
s_bird_table.anonymous = true

name = s_bird_table:option(Value, "name", "Table name", "Descriptor ID of the table")

-- Named section: "global"

s_bird_global = m:section(NamedSection, "global", "global", "Global options", "Basic Bird6 settings")
s_bird_global.addremove = False

id = s_bird_global:option(Value, "router_id", "Router ID", "Identification number of the router. By default, is the router's IP.")

lf = s_bird_global:option(Value, "log_file", "Log File", "File used to store log related data.")

l = s_bird_global:option(MultiValue, "log", "Log", "Set which elements do you want to log.")
l:value("all", "All")
l:value("info", "Info")
l:value("warning","Warning")
l:value("error","Error")
l:value("fatal","Fatal")
l:value("debug","Debug")
l:value("trace","Trace")
l:value("remote","Remote")
l:value("auth","Auth")

d = s_bird_global:option(MultiValue, "debug", "Debug", "Set which elements do you want to debug.")
d:value("all", "All")
d:value("states","States")
d:value("routes","Routes")
d:value("filters","Filters")
d:value("interfaces","Interfaces")
d:value("events","Events")
d:value("packets","Packets")

listen_addr = s_bird_global:option(Value, "listen_bgp_addr", "BGP Address", "Set the Addres that BGP will listen to.")
listen_addr.optional = true

listen_port = s_bird_global:option(Value, "listen_bgp_port", "BGP Port", "Set the port that BGP will listen to.")
listen_port.optional = true

listen_dual = s_bird_global:option(Flag, "listen_bgp_dual", "BGP Dual/ipv6", "Set if BGP connections will listen ipv6 only 'ipv6only' or both ipv4/6 'dual' routes")
listen_dual.optional = true


function m.on_commit(self,map)
        luci.sys.call('/etc/init.d/bird6 stop; /etc/init.d/bird6 start')
end

return m
