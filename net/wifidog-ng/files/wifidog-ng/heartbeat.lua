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

local uloop = require "uloop"
local http = require "socket.http"
local util = require "wifidog-ng.util"
local config = require "wifidog-ng.config"

local M = {}

local timer = nil
local start_time = os.time()

local function heartbeat()
    local cfg = config.get()

    timer:set(1000 * cfg.checkinterval)

    local sysinfo = util.ubus("system", "info")

    local url = string.format("%s&sys_uptime=%d&sys_memfree=%d&sys_load=%d&wifidog_uptime=%d",
        cfg.ping_url, sysinfo.uptime, sysinfo.memory.free, sysinfo.load[1], os.time() - start_time)
    http.request(url)
end

function M.start()
    timer = uloop.timer(heartbeat, 1000)
end

return M
