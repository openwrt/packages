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
local uci = require "uci"

-- System config
local context = uci.cursor("/etc/config", "/tmp/.uci")

-- scalar index
local sysDesc             = 1
local sysObjectID         = 2
local sysUpTime           = 3
local sysContact          = 4
local sysName             = 5
local sysLocation         = 6
local sysServices         = 7
local sysORLastChange     = 8

-- table index
local sysORTable          = 9

-- entry index
local sysOREntry          = 1

-- list index
local sysORIndex          = 1
local sysORID             = 2
local sysORDesc           = 3
local sysORUpTime         = 4

local startup_time = 0
local or_last_changed_time = 0

local function mib_system_startup(time)
    startup_time = time
    or_last_changed_time = time
end

mib_system_startup(os.time())

local sysGroup = {}
local or_oid_cache = {}
local or_index_cache = {}
local or_table_cache = {}

local or_table_reg = function (oid, desc)
    local row = {}
    row['oid'] = {}
    for i in string.gmatch(oid, "%d") do
        table.insert(row['oid'], tonumber(i))
    end
    row['desc'] = desc
    row['uptime'] = os.time()
    table.insert(or_table_cache, row)
    
    or_last_changed_time = os.time()

    or_oid_cache[oid] = #or_table_cache

    or_index_cache = {}
    for i in ipairs(or_table_cache) do
        table.insert(or_index_cache, i)
    end
end

local or_table_unreg = function (oid)
    local or_idx = or_oid_cache[oid]

    if or_table_cache[or_idx] ~= nil then
        table.remove(or_table_cache, or_idx)
        or_last_changed_time = os.time()

        or_index_cache = {}
        for i in ipairs(or_table_cache) do
            table.insert(or_index_cache, i)
        end
    end
end

local last_load_time = os.time()
local function need_to_reload()
    if os.difftime(os.time(), last_load_time) < 3 then
        return false
    else
        last_load_time = os.time()
        return true
    end
end

local function load_config()
    if need_to_reload() == true then
        context:load("smartsnmpd")
    end
end

context:load("smartsnmpd")

local sysMethods = {
    ["or_table_reg"] = or_table_reg, 
    ["or_table_unreg"] = or_table_unreg
}
mib.module_method_register(sysMethods)

sysGroup = {
    rocommunity = 'public',
    [sysDesc]         = mib.ConstString(function () load_config() return mib.sh_call("uname -a") end),
    [sysObjectID]     = mib.ConstOid(function ()
                                         load_config()
                                         local oid
                                         local objectid
                                         context:foreach("smartsnmpd", "smartsnmpd", function (s)
                                             objectid = s.objectid
                                         end)
                                         if objectid ~= nil then
                                            oid = {}
                                            for i in string.gmatch(objectid, "%d+") do
                                                table.insert(oid, tonumber(i))
                                            end
                                         end
                                         return oid
                                     end),
    [sysUpTime]       = mib.ConstTimeticks(function () load_config() return os.difftime(os.time(), startup_time) * 100 end),
    [sysContact]      = mib.ConstString(function () 
                                            load_config()
                                            local contact
                                            context:foreach("smartsnmpd", "smartsnmpd", function (s)
                                                contact = s.contact
                                            end)
                                            return contact
                                        end),
    [sysName]         = mib.ConstString(function () load_config() return mib.sh_call("uname -n") end),
    [sysLocation]     = mib.ConstString(function ()
                                            load_config()
                                            local location
                                            context:foreach("smartsnmpd", "smartsnmpd", function (s)
                                                location = s.location
                                            end)
                                            return location
                                        end),
    [sysServices]     = mib.ConstInt(function ()
                                         load_config()
                                         local services
                                         context:foreach("smartsnmpd", "smartsnmpd", function (s)
                                             services = tonumber(s.services)
                                         end)
                                         return services
                                     end),
    [sysORLastChange] = mib.ConstTimeticks(function () load_config() return os.difftime(os.time(), or_last_changed_time) * 100 end),
    [sysORTable]      = {
        [sysOREntry]  = {
            [sysORIndex]  = mib.UnaIndex(function () load_config() return or_index_cache end),
            [sysORID]     = mib.ConstOid(function (i) load_config() return or_table_cache[i].oid end),
            [sysORDesc]   = mib.ConstString(function (i) load_config() return or_table_cache[i].desc end),
            [sysORUpTime] = mib.ConstTimeticks(function (i) load_config() return os.difftime(os.time(), or_table_cache[i].uptime) * 100 end),
        }
    }
}

return sysGroup
