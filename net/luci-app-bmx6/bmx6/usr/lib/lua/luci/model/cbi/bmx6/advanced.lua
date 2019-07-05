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

m = Map("bmx6", "bmx6")

local bmx6json = require("luci.model.bmx6json")
local util = require("luci.util")
local http = require("luci.http")
local sys = require("luci.sys")

local options = bmx6json.get("options")
if options == nil or options.OPTIONS == nil then
	m.message = "bmx6-json plugin is not running or some mistake in luci-bmx6 configuration, check /etc/config/luci-bmx6"
	options = {}
else
	options = options.OPTIONS
end

local general = m:section(NamedSection,"general","bmx6")
general.addremove = true

local name = ""
local help = ""
local value = nil
local _,o

for _,o in ipairs(options) do
	if o.name ~= nil and o.CHILD_OPTIONS == nil and o.configurable == 1 then
		help = ""
		name = o.name

		if o.help ~= nil then
			help = bmx6json.text2html(o.help)
		end

		if o.syntax ~= nil then
			help = help .. "<br/><strong>Syntax: </strong>" .. bmx6json.text2html(o.syntax)
		end

		if o.def ~= nil then
			help = help .. "<strong> Default: </strong>" .. o.def
		end

		value = general:option(Value,name,name,help)

	end
end

function m.on_commit(self,map)
	local err = sys.call('bmx6 -c --configReload > /tmp/bmx6-luci.err.tmp')
	if err ~= 0 then
		m.message = sys.exec("cat /tmp/bmx6-luci.err.tmp")
	end
end

return m

