--[[
  Copyright (C) 2018 Jianhui Zhao <jianhuizhao329@gmail.com>
 
  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.
 
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.
 
  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
  USA
 --]]

local _ubus = require "ubus"
local _ubus_connection = nil

local M = {}

function M.arp_get(ifname, ipaddr)
    for l in io.lines("/proc/net/arp") do
        local f = {}

        for e in string.gmatch(l, "%S+") do
            f[#f + 1] = e
        end

        if f[1] == ipaddr and f[6] == ifname then
            return f[4]
        end
    end
end

function M.read_file(path, len)
    local file = io.open(path, "r")
    if not file then return nil end
    
    if not len then len = "*a" end

    local data = file:read(len)
    file:close()

    return data
end

local ubus_codes = {
	"INVALID_COMMAND",
    "INVALID_ARGUMENT",
    "METHOD_NOT_FOUND",
    "NOT_FOUND",
    "NO_DATA",
    "PERMISSION_DENIED",
    "TIMEOUT",
    "NOT_SUPPORTED",
    "UNKNOWN_ERROR",
    "CONNECTION_FAILED"
}

function M.ubus(object, method, data)
	if not _ubus_connection then
     	_ubus_connection = _ubus.connect()
     	assert(_ubus_connection, "Unable to establish ubus connection")
	end
	
	if object and method then
    	if type(data) ~= "table" then
        	data = { }
     	end
    	local rv, err = _ubus_connection:call(object, method, data)
    	return rv, err, ubus_codes[err]
	elseif object then
    	return _ubus_connection:signatures(object)
	else
    	return _ubus_connection:objects()
	end
end

return M
