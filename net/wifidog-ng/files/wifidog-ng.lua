#!/usr/bin/env lua

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
local uh = require "uhttpd"
local auth = require "wifidog-ng.auth"
local ubus = require "wifidog-ng.ubus"
local version = require "wifidog-ng.version"
local heartbeat = require "wifidog-ng.heartbeat"

uh.log(uh.LOG_INFO, "Version: " .. version.string())

uloop.init()

ubus.init()
auth.init()
heartbeat.start()

uloop.run()
