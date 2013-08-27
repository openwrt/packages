--[[
    Copyright (C) 2011 Pau Escrich <pau@dabax.net>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

    The full GNU General Public License is included in this distribution in
    the file called "COPYING".
--]]

local sys = require("luci.sys")
local bmx6json = require("luci.model.bmx6json")

m = Map("bmx6", "bmx6")

-- tunOut
local tunnelsOut = m:section(TypedSection,"tunOut",translate("Networks to fetch"),translate("Gateways announcements to fetch"))
tunnelsOut.addremove = true
tunnelsOut.anonymous = true
tunnelsOut:option(Value,"tunOut","Name")
tunnelsOut:option(Value,"network", translate("Network to fetch"))

local tunoptions = bmx6json.getOptions("tunOut")
local _,o
for _,o in ipairs(tunoptions) do
        if o.name ~= nil  and o.name ~= "network" then
		help = bmx6json.getHtmlHelp(o)
		value = tunnelsOut:option(Value,o.name,o.name,help)
		value.optional = true
	end
end


-- tunOut
local tunnelsIn = m:section(TypedSection,"tunIn",translate("Networks to offer"),translate("Gateways to announce in the network"))
tunnelsIn.addremove = true
tunnelsIn.anonymous = true
tunnelsIn:option(Value,"tunIn","Name")
tunnelsIn:option(Value,"network", translate("Network to offer"))

local tunInoptions = bmx6json.getOptions("tunIn")
local _,o
for _,o in ipairs(tunInoptions) do
        if o.name ~= nil  and o.name ~= "network" then
		help = bmx6json.getHtmlHelp(o)
		value = tunnelsIn:option(Value,o.name,o.name,help)
		value.optional = true
	end
end

function m.on_commit(self,map)
	--Not working. If test returns error the changes are still commited
	local msg = bmx6json.testandreload()
	if msg ~= nil then
		m.message = msg
	end
end

return m
