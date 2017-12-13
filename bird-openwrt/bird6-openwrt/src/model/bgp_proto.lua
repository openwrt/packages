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
local common_string = "Valid options are:<br />" .. "1. all (All the routes)<br />" .. "2. none (No routes)<br />" .. "3. filter <b>Your_Filter_Name</b> (Call a specific filter from any of the available in the filters files)"
local imp_string = "Set if the protocol must import routes.<br />" .. common_string
local exp_string = "Set if the protocol must export routes.<br />" .. common_string

m=Map("bird6", "Bird6 BGP protocol's configuration")

tab_templates = {}
uci:foreach('bird6', 'bgp_template', function (s)
	local name = s[".name"]
	if (name ~= nil) then
		table.insert(tab_templates, name)
	end
end)

--
-- BGP TEMPLATES
--
sect_templates = m:section(TypedSection, "bgp_template", "BGP Templates", "Configuration of the templates used in BGP instances.")
sect_templates.addremove = true
sect_templates.anonymous = false

disabled = sect_templates:option(Flag, "disabled", "Disabled", "Enable/Disable BGP Protocol")
disabled.optional=true

description = sect_templates:option(TextValue, "description", "Description", "Description of the current BGP instance")
description.optional = true

table = sect_templates:option(ListValue, "table", "Table", "Set the table used for BGP Routing")
table.optional=true
uci:foreach("bird6", "table",
	function (s)
		table:value(s.name)
	end)
table:value("")
table.default = ""

igp_table = sect_templates:option(ListValue, "igp_table", "IGP Table", "Select the IGP Routing Table to use. Hint: usually the same table as BGP.")
igp_table.optional = true
uci:foreach("bird6", "table",
function(s)
    igp_table:value(s.name)
end)
igp_table:value("")
igp_table.default = ""

import = sect_templates:option(Value, "import", "Import", imp_string)
import.optional=true

export = sect_templates:option(Value, "export", "Export", exp_string)
export.optional=true

source_addr = sect_templates:option(Value, "source_address", "Source Address", "Source address for BGP routing. By default uses Router ID")
source_addr.optional = true

local_address = sect_templates:option(Value, "local_address", "Local BGP address", "")
local_address.optional = false

local_as = sect_templates:option(Value, "local_as", "Local AS", "")
local_as.optional = false

next_hop_self = sect_templates:option(Flag, "next_hop_self", "Next hop self", "Avoid next hop calculation and advertise own source address as next hop")
next_hop_self.default = nil
next_hop_self.optional = true

next_hop_keep = sect_templates:option(Flag, "next_hop_keep", "Next hop keep", "Forward the received Next Hop attribute event in situations where the local address should be used instead, like subneting")
next_hop_keep.default = nil
next_hop_keep.optional = true

rr_client = sect_templates:option(Flag, "rr_client", "Route Reflector server", "This router serves as a Route Reflector server and treats neighbors as clients")
rr_client.default = nil
rr_client.optional = true

rr_cluster_id = sect_templates:option(Value, "rr_cluster_id", "Route Reflector Cluster ID", "Identificator of the RR cluster. By default uses the Router ID")
rr_cluster_id.optional = true

import_trigger = sect_templates:option(Flag, "import_trigger", "Import Limit", "Enable Routes Import limit settings")
import_trigger.default = 0
import_trigger.rmempty = false
import_trigger.optional = false

import_limit = sect_templates:option(Value, "import_limit", "Routes import limit", "Specify an import route limit.")
import_limit:depends({import_trigger = "1"})
import_limit.rmempty = true

import_limit_action = sect_templates:option(ListValue, "import_limit_action", "Routes import limit action", "Action to take when import routes limit ir reached")
import_limit_action:depends({import_trigger = "1"})
import_limit_action:value("warn")
import_limit_action:value("block")
import_limit_action:value("disable")
import_limit_action:value("restart")
import_limit_action.default = "warn"
import_limit_action.rmempty = true

export_trigger = sect_templates:option(Flag, "export_trigger", "Export Limit", "Enable Routes Export limit settings")
export_trigger.default = 0
export_trigger.rmempty = false
export_trigger.optional = false

export_limit = sect_templates:option(Value, "export_limit", "Routes export limit", "Specify an export route limit.")
export_limit:depends({export_trigger = "1"})
export_limit.rmempty = true

export_limit_action = sect_templates:option(ListValue, "export_limit_action", "Routes export limit action", "Action to take when export routes limit is reached")
export_limit_action:depends({export_trigger = "1"})
export_limit_action.rmempty = true
export_limit_action:value("warn")
export_limit_action:value("block")
export_limit_action:value("disable")
export_limit_action:value("restart")
export_limit_action.default = "warn"

receive_trigger = sect_templates:option(Flag, "receive_trigger", "Received Limit", "Enable Routes Received Limit settings")
receive_trigger.default = 0
receive_trigger.rmempty = false
receive_trigger.optional = false

receive_limit = sect_templates:option(Value, "receive_limit", "Routes received limit", "Specify a received route limit.")
receive_limit:depends({receive_trigger = "1"})
receive_limit.rmempty = true

receive_limit_action = sect_templates:option(ListValue, "receive_limit_action", "Routes received limit action", "Action to take when received routes limit is reached")
receive_limit_action:depends({receive_trigger = "1"})
receive_limit_action:value("warn")
receive_limit_action:value("block")
receive_limit_action:value("disable")
receive_limit_action:value("restart")
receive_limit_action.default = "warn"
receive_limit_action.rmempty= true

--
-- BGP INSTANCES
--
sect_instances = m:section(TypedSection, "bgp", "BGP Instances", "Configuration of the BGP protocol instances")
sect_instances.addremove = true
sect_instances.anonymous = false

templates = sect_instances:option(ListValue, "template", "Templates", "Available BGP templates")
uci:foreach("bird6", "bgp_template",
	function(s)
		templates:value(s[".name"])
	end)
templates:value("")

disabled = sect_instances:option(Flag, "disabled", "Disabled", "Enable/Disable BGP Protocol")
disabled.optional = false
disabled.rmempty = false
disabled.default = nil

description = sect_instances:option(TextValue, "description", "Description", "Description of the current BGP instance")
description.optional = true

table = sect_instances:option(ListValue, "table", "Table", "Set the table used for BGP Routing")
table.optional=true
uci:foreach("bird6", "table",
    function (s)
        table:value(s.name)
    end)
table:value("")
table.default = ""

igp_table = sect_instances:option(ListValue, "igp_table", "IGP Table", "Select the IGP Routing Table to use. Hint: usually the same table as BGP.")
igp_table.optional = true
uci:foreach("bird6", "table",
function(s)
    igp_table:value(s.name)
end)
igp_table:value("")
igp_table.default = ""

import = sect_instances:option(Value, "import", "Import", imp_string)
import.optional=true

export = sect_instances:option(Value, "export", "Export", exp_string)
export.optional=true

source_address = sect_instances:option(Value, "source_address", "Source Address", "Source address for BGP routing. By default uses Router ID")
source_address.optional = true

local_address = sect_instances:option(Value, "local_address", "Local BGP address", "")
local_address.optional=true

local_as = sect_instances:option(Value, "local_as", "Local AS", "")
local_as.optional=true

neighbor_address = sect_instances:option(Value, "neighbor_address", "Neighbor IP Address", "")
neighbor_address.optional = false

neighbor_as = sect_instances:option(Value, "neighbor_as", "Neighbor AS", "")
neighbor_as.optional = false

next_hop_self = sect_instances:option(Flag, "next_hop_self", "Next hop self", "Avoid next hop calculation and advertise own source address as next hop")
next_hop_self.default = nil
next_hop_self.optional = true

next_hop_keep = sect_instances:option(Flag, "next_hop_keep", "Next hop keep", "Forward the received Next Hop attribute event in situations where the local address should be used instead, like subneting")
next_hop_keep.default = nil
next_hop_keep.optional = true

rr_client = sect_instances:option(Flag, "rr_client", "Route Reflector server", "This router serves as a Route Reflector server and treats neighbors as clients")
rr_client.default = nil
rr_client.optional = true

rr_cluster_id = sect_instances:option(Value, "rr_cluster_id", "Route Reflector Cluster ID", "Identificator of the RR cluster. By default uses the Router ID")
rr_cluster_id.optional = true

import_trigger = sect_instances:option(Flag, "import_trigger", "Import Limit", "Enable Routes Import limit settings")
import_trigger.default = 0
import_trigger.rmempty = false
import_trigger.optional = false

import_limit = sect_instances:option(Value, "import_limit", "Routes import limit", "Specify an import route limit.")
import_limit:depends({import_trigger = "1"})
import_limit.rmempty = true

import_limit_action = sect_instances:option(ListValue, "import_limit_action", "Routes import limit action", "Action to take when import routes limit ir reached")
import_limit_action:depends({import_trigger = "1"})
import_limit_action:value("warn")
import_limit_action:value("block")
import_limit_action:value("disable")
import_limit_action:value("restart")
import_limit_action.default = "warn"
import_limit_action.rmempty = true

export_trigger = sect_instances:option(Flag, "export_trigger", "Export Limit", "Enable Routes Export limit settings")
export_trigger.default = 0
export_trigger.rmempty = false
export_trigger.optional = false

export_limit = sect_instances:option(Value, "export_limit", "Routes export limit", "Specify an export route limit.")
export_limit:depends({export_trigger = "1"})
export_limit.rmempty = true

export_limit_action = sect_instances:option(ListValue, "export_limit_action", "Routes export limit action", "Action to take when export routes limit is reached")
export_limit_action:depends({export_trigger = "1"})
export_limit_action.rmempty = true
export_limit_action:value("warn")
export_limit_action:value("block")
export_limit_action:value("disable")
export_limit_action:value("restart")
export_limit_action.default = "warn"

receive_trigger = sect_instances:option(Flag, "receive_trigger", "Received Limit", "Enable Routes Received Limit settings")
receive_trigger.default = 0
receive_trigger.rmempty = false
receive_trigger.optional = false

receive_limit = sect_instances:option(Value, "receive_limit", "Routes received limit", "Specify a received route limit.")
receive_limit:depends({receive_trigger = "1"})
receive_limit.rmempty = true

receive_limit_action = sect_instances:option(ListValue, "receive_limit_action", "Routes received limit action", "Action to take when received routes limit is reached")
receive_limit_action:depends({receive_trigger = "1"})
receive_limit_action:value("warn")
receive_limit_action:value("block")
receive_limit_action:value("disable")
receive_limit_action:value("restart")
receive_limit_action.default = "warn"
receive_limit_action.rmempty= true

function m.on_commit(self,map)
        luci.sys.exec('/etc/init.d/bird6 restart')
end

return m
