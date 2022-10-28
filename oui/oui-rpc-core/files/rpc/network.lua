local M = {}

local ubus = require 'ubus'
local fs = require 'oui.fs'
local uci = require 'uci'

function M.dhcp_leases()
    local c = uci.cursor()
    local leases = {}
    local leasefile = c:get('dhcp', '@dnsmasq[0]', 'leasefile') or '/tmp/dhcp.leases'

    if not fs.access(leasefile) then
        return { leases = leases }
    end

    local now = os.time()

    for line in io.lines(leasefile) do
        local ts, mac, addr, name = line:match("(%S+) +(%S+) +(%S+) +(%S+)")
        local expire

        ts = tonumber(ts)

        if ts > now then
            expire = ts - now
        elseif ts > 0 then
            expire = 0
        else
            expire = -1
        end

        leases[#leases + 1] = {
            ipaddr = addr,
            macaddr = mac,
            hostname = name,
            expire = expire
        }
    end

    return { leases = leases }
end

local function get_networks()
    local con = ubus.connect()
    local status = con:call('network.interface', 'dump', {})
    con:close()
    return status.interface
end

local function get_networks_by_route(target, mask)
    local networks = get_networks()
    local r = {}

    for _, network in ipairs(networks) do
        for _, route in ipairs(network.route) do
            if route.target == target and route.mask == mask then
                r[#r + 1] = network
                break
            end
        end
    end

    return r
end

function M.get_networks()
    return { networks = get_networks() }
end

function M.get_wan_networks()
    return { networks = get_networks_by_route('0.0.0.0', 0) }
end

function M.get_wan6_networks()
    return { networks = get_networks_by_route('::', 0) }
end

return M
