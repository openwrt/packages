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
local util = require "wifidog-ng.util"

local M = {}

local cfg = {}

function M.parse()
    local c = uci.cursor()

    c:foreach('wifidog-ng', 'gateway', function(s)
        local port = s.port or 2060
        local ssl_port = s.ssl_port or 8443
        local interface = s.interface or "lan"
        local checkinterval = s.checkinterval or 30
        local client_timeout = s.client_timeout or 5
        local temppass_time = s.temppass_time or 30
        local id = s.id
        local address = s.address

        cfg.gw_port = tonumber(port)
        cfg.gw_ssl_port = tonumber(ssl_port)
        cfg.checkinterval = tonumber(checkinterval)
        cfg.client_timeout = tonumber(client_timeout)
        cfg.temppass_time = tonumber(temppass_time)
        cfg.gw_address = s.address
        cfg.gw_id = s.id

        local st = util.ubus("network.interface." .. interface, "status")
        cfg.gw_ifname = st.device

        if not cfg.gw_address then
            cfg.gw_address = st["ipv4-address"][1].address
        end

        if not cfg.gw_id then
            local devst = util.ubus("network.device", "status", {name = st.device})
            local macaddr = devst.macaddr
            cfg.gw_id = macaddr:gsub(":", ""):upper()
        end
    end)

    c:foreach('wifidog-ng', 'server', function(s)
        local host = s.host
        local path = s.path or "/wifidog/"
        local gw_port = cfg.gw_port
        local gw_id = cfg.gw_id
        local gw_address = cfg.gw_address
        local ssid = cfg.ssid or ""
        local proto, port = "http", ""
        

        if s.port ~= "80" and s.port ~= "443" then
            port = ":" .. s.port
        end

        if s.ssl == "1" then
            proto = "https"
        end

        cfg.login_url = string.format("%s://%s%s%s%s?gw_address=%s&gw_port=%d&gw_id=%s&ssid=%s",
            proto, host, port, path, s.login_path, gw_address, gw_port, gw_id, ssid)

        cfg.auth_url = string.format("%s://%s%s%s%s?gw_id=%s",
            proto, host, port, path, s.auth_path, gw_id)

        cfg.ping_url = string.format("%s://%s%s%s%s?gw_id=%s",
            proto, host, port, path, s.ping_path, gw_id)

        cfg.portal_url = string.format("%s://%s%s%s%s?gw_id=%s",
            proto, host, port, path, s.portal_path, gw_id)

        cfg.msg_url = string.format("%s://%s%s%s%s?gw_id=%s",
            proto, host, port, path, s.msg_path, gw_id)
    end)

    cfg.parsed = true
end

function M.get()
    if not cfg.parsed then
        M.parse()
    end

    return cfg
end

function M.add_whitelist(typ, value)
    local c = uci.cursor()
    local opt

    if typ == "mac" then
        typ = "validated_user"
        opt = "mac"
    elseif typ == "domain" then
        typ = "validated_domain"
        opt = "domain"
    else
        return
    end

    local exist = false
    c:foreach("wifidog-ng", typ, function(s)
        if s[opt] == value then
            exist = true
        end
    end)

    if not exist then
        local s = c:add("wifidog-ng", typ)
        c:set("wifidog-ng", s, opt, value)
        c:commit("wifidog-ng")
    end
end

function M.del_whitelist(typ, value)
    local c = uci.cursor()
    local opt

    if typ == "mac" then
        typ = "validated_user"
        opt = "mac"
    elseif typ == "domain" then
        typ = "validated_domain"
        opt = "domain"
    else
        return
    end

    c:foreach("wifidog-ng", typ, function(s)
        if s[opt] == value then
            c:delete("wifidog-ng", s[".name"])
        end
    end)

    c:commit("wifidog-ng")
end

return M
