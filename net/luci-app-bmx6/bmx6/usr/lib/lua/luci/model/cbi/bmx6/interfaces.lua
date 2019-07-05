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
local m = Map("bmx6", "bmx6")

local eth_int = sys.net.devices()
local interfaces = m:section(TypedSection,"dev","Devices","")
interfaces.addremove = true
interfaces.anonymous = true

local intlv = interfaces:option(ListValue,"dev","Device")

for _,i in ipairs(eth_int) do
	intlv:value(i,i)
end

-- Getting json and looking for device section
local json = bmx6json.get("options")

if json == nil or json.OPTIONS == nil then
	m.message = "bmx6-json plugin is not running or some mistake in luci-bmx6 configuration, check /etc/config/luci-bmx6"
	json = {}
else
	json = json.OPTIONS
end

local dev = {}
for _,j in ipairs(json) do
	if j.name == "dev" and j.CHILD_OPTIONS ~= nil then
		dev = j.CHILD_OPTIONS
		break
	end
end

local help = ""
local name = ""

for _,o in ipairs(dev) do
	if o.name ~= nil then
		help = ""
		name = o.name
		if o.help ~= nil then
			help = bmx6json.text2html(o.help)
		end

		if o.syntax ~= nil then
			help = help .. "<br/><strong>Syntax: </strong>" .. bmx6json.text2html(o.syntax)
		end

		value = interfaces:option(Value,name,name,help)
		value.optional = true
	end
end


return m

