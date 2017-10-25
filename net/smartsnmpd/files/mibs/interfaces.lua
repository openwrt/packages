-- 
-- This file is part of SmartSNMP
-- Copyright (C) 2014, Credo Semiconductor Inc.
-- 
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
-- 

local mib = require "smartsnmp"
require "ubus"
require "uloop"

uloop.init()

local conn = ubus.connect()
if not conn then
    error("Failed to connect to ubusd")
end

local if_cache = {}
local if_status_cache = {}
local if_index_cache = {}

local last_load_time = os.time()
local function need_to_reload()
    if os.time() - last_load_time >= 3 then
        last_load_time = os.time()
        return true
    else
        return false
    end
end

local function load_config()
    if need_to_reload() == true then
        if_cache = {}
        if_status_cache = {}
        if_index_cache = {}

        -- if description
        for k, v in pairs(conn:call("network.device", "status", {})) do
            if_status_cache[k] = {}
        end

        for name_ in pairs(if_status_cache) do
            for k, v in pairs(conn:call("network.device", "status", { name = name_ })) do
                if k == 'mtu' then
                    if_status_cache[name_].mtu = v
                elseif k == 'macaddr' then
                    if_status_cache[name_].macaddr = v
                elseif k == 'up' then
                    if v == true then            
                        if_status_cache[name_].up = 1
                    else
                        if_status_cache[name_].up = 2
                    end
                elseif k == 'statistics' then
                    for item, stat in pairs(v) do
                        if item == 'rx_bytes' then
                            if_status_cache[name_].in_octet = stat
                        elseif item == 'tx_bytes' then
                            if_status_cache[name_].out_octet = stat
                        elseif item == 'rx_errors' then
                            if_status_cache[name_].in_errors = stat
                        elseif item == 'tx_errors' then
                            if_status_cache[name_].out_errors = stat
                        elseif item == 'rx_dropped' then
                            if_status_cache[name_].in_discards = stat
                        elseif item == 'tx_dropped' then
                            if_status_cache[name_].out_discards = stat
                        end
                    end
                end
            end
        end

        if_cache['desc'] = {}
        for name, status in pairs(if_status_cache) do
            table.insert(if_cache['desc'], name)
            for k, v in pairs(status) do
                if if_cache[k] == nil then if_cache[k] = {} end
                table.insert(if_cache[k], v)
            end
        end

        -- if index
        for i in ipairs(if_cache['desc']) do
            table.insert(if_index_cache, i)
        end
    end
end

mib.module_methods.or_table_reg("1.3.6.1.2.1.2", "The MIB module for managing Interfaces implementations")

local ifGroup = {
    [1]  = mib.ConstInt(function () load_config() return #if_index_cache end),
    [2] = {
        [1] = {
            [1] = mib.ConstIndex(function () load_config() return if_index_cache end),
            [2] = mib.ConstString(function (i) load_config() return if_cache['desc'][i] end),
            [4] = mib.ConstInt(function (i) load_config() return if_cache['mtu'][i] end),
            [6] = mib.ConstString(function (i) load_config() return if_cache['macaddr'][i] end),
            [8] = mib.ConstInt(function (i) load_config() return if_cache['up'][i] end),
            [10] = mib.ConstCount(function (i) load_config() return if_cache['in_octet'][i] end),
            [13] = mib.ConstCount(function (i) load_config() return if_cache['in_discards'][i] end),
            [14] = mib.ConstCount(function (i) load_config() return if_cache['in_errors'][i] end),
            [16] = mib.ConstCount(function (i) load_config() return if_cache['out_octet'][i] end),
            [19] = mib.ConstCount(function (i) load_config() return if_cache['out_discards'][i] end),
            [20] = mib.ConstCount(function (i) load_config() return if_cache['out_errors'][i] end),
        }
    }
}

return ifGroup
