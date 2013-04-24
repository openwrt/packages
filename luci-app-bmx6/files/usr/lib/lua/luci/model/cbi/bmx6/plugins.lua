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

m = Map("bmx6", "bmx6")
plugins_dir = {"/usr/lib/","/var/lib","/lib"}

plugin = m:section(TypedSection,"plugin","Plugin")
plugin.addremove = true
plugin.anonymous = true
plv = plugin:option(ListValue,"plugin", "Plugin")

for _,d in ipairs(plugins_dir) do
	pl = luci.sys.exec("cd "..d..";ls bmx6_*")
	if #pl > 6 then
		for _,v in ipairs(luci.util.split(pl,"\n")) do
			plv:value(v,v)
		end
	end
end


function m.on_commit(self,map)
	local err = sys.call('/etc/init.d/bmx6 restart')
	if err ~= 0 then
		m.message = sys.exec("Cannot restart bmx6")
	end
end


return m

