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

local uci = require "uci"
local ubus = require "ubus"
local http = require "socket.http"
local auth = require "wifidog-ng.auth"
local config = require "wifidog-ng.config"


local M = {}

local conn = nil

local ubus_codes = {
    ["INVALID_COMMAND"] = 1,
    ["INVALID_ARGUMENT"] = 2,
    ["METHOD_NOT_FOUND"] = 3,
    ["NOT_FOUND"] = 4,
    ["NO_DATA"] = 5,
    ["PERMISSION_DENIED"] = 6,
    ["TIMEOUT"] = 7,
    ["NOT_SUPPORTED"] = 8,
    ["UNKNOWN_ERROR"] = 9,
    ["CONNECTION_FAILED"] = 10
}

local function reload_validated_domain()
    local c = uci.cursor()

    local file = io.open("/tmp/dnsmasq.d/wifidog-ng", "w")

    c:foreach("wifidog-ng", "validated_domain", function(s)
        file:write("ipset=/" .. s.domain .. "/wifidog-ng-ip\n")
    end)
    file:close()

    os.execute("/etc/init.d/dnsmasq restart &")
end

local methods = {
    ["wifidog-ng"] = {
        roam = {
            function(req, msg)
                local cfg = config.get()

                if not msg.ip or not msg.mac then
                    return ubus_codes["INVALID_ARGUMENT"]
                end

                local url = string.format("%s&stage=roam&ip=%s&mac=%s", cfg.auth_url, msg.ip, msg.mac)
                local r = http.request(url) or ""
                local token = r:match("token=(%w+)")
                if token then
                    auth.new_term(msg.ip, msg.mac, token)
                end
            end, {ip = ubus.STRING, mac = ubus.STRING }
        },
        term = {
            function(req, msg)
                if msg.action == "show" then
                    conn:reply(req, {terms = auth.get_terms()});
                    return
                end

                if not msg.action or not msg.mac then
                    return ubus_codes["INVALID_ARGUMENT"]
                end

                if msg.action == "add" then
                    auth.allow_user(mac)
                elseif msg.action == "del" then
                    auth.deny_user(mac)
                end
            end, {action = ubus.STRING, mac = ubus.STRING }
        },
        whitelist = {
            function(req, msg)
                if not msg.action or not msg.type or not msg.value then
                    return ubus_codes["INVALID_ARGUMENT"]
                end

                if msg.action == "add" then
                    config.add_whitelist(msg.type, msg.value)
                    if msg.type == "mac" then
                        auth.allow_user(msg.value)
                    end
                elseif msg.action == "del" then
                    config.del_whitelist(msg.type, msg.value)
                    if msg.type == "mac" then
                        auth.deny_user(msg.value)
                    end
                end

                if msg.type == "domain" then
                    reload_validated_domain()
                end
            end, {action = ubus.STRING, type = ubus.STRING, value = ubus.STRING }
        },
    }
}

function M.init()
    conn = ubus.connect()
    if not conn then
        error("Failed to connect to ubus")
    end

    conn:add(methods)
end

return M
