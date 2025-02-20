if not submitToMainThread then
    -- stub for testing outside of dnsdist
    function submitToMainThread(cmd, data)
        print("cmd",cmd)
        for k,v in pairs(data) do
            print(k,v)
        end
    end
end

-- # ubus call dhcp ipv4leases
-- {
--     "device": {
--         "br-lan": {
--             "leases": [
--                 {
--                     "mac": "dca632cd93a6",
--                     "hostname": "archimedes",
--                     "accept-reconf-nonce": false,
--                     "reqopts": "1,2,6,12,15,26,28,121,3,33,40,41,42,119,249,252,17",
--                     "flags": [
--                         "bound"
--                     ],
--                     "address": "192.168.52.124",
--                     "valid": 43160
--                 }
--             ]
--         }
--     }
-- }

-- # ubus call dhcp ipv6leases
-- {
--         "device": {
--                 "br-lan": {
--                         "leases": [
--                                 {
--                                         "duid": "00030001dca632c0d5f0",
--                                         "iaid": 0,
--                                         "hostname": "",
--                                         "accept-reconf": false,
--                                         "assigned": 2589,
--                                         "flags": [
--                                                "bound"
--                                         ],
--                                         "ipv6-addr": [
--                                                 {
--                                                         "address": "fdc0:b385:de66::a1d",
--                                                         "preferred-lifetime": -1,
--                                                         "valid-lifetime": -1
--                                                 }
--                                         ],
--                                         "valid": 56
--                                 }
--                         ]
--                 }
--         }
-- }


local ubus = require 'ubus'   -- opkg install libubus-lua
local uloop = require 'uloop' -- opkg install libubox-lua

uloop.init()

local conn = ubus.connect()
if not conn then
    error("Failed to connect to ubusd")
end

local byName4 = {} -- key: hostname. value: {ip=.., expire=..} - expire is a timestamp, not a TTL
local byIP4 = {} -- key: IP. value: hostname as string.

local byName6 = {} -- key: hostname. value: {ip=.., expire=..} - expire is a timestamp, not a TTL
local byIP6 = {} -- key: IP. value: hostname as string.

local leasetime = 12*3600  -- TODO: fetch from uci

local now = os.time()

local function send(cmd, name, ip, proto)
    submitToMainThread(cmd, {ip=ip, name=name, proto=proto})
end

local function delEntry(name, ip, proto, byName, byIP)
    byName[name] = nil
    byIP[ip] = nil
    send('del', name, ip, proto)
end

local function setEntry(name, ip, ttl, proto, byName, byIP)
    now = os.time()
    if byName[name] and byName[name].ip == ip then
        -- just update the expiry
        byName[name].expire = now + ttl
        return
    end

    if byName[name] then
        -- the name exists, but with the wrong IP
        delEntry(name, byName[name].ip, proto, byName, byIP)
    end

    if byIP[ip] then
        -- the IP exists, but with the wrong name
        delEntry(byIP[ip], ip, proto, byName, byIP)
    end

    -- we are ready to register the entry

    byName[name] = { ip=ip, expire=now+ttl}
    byIP[ip] = name
    send('add', name, ip, proto)
end

local function handleEvent(msg, name)
    -- { "dhcp.ack": {"mac":"dc:a6:32:cd:93:a6","ip":"192.168.52.124","name":"archimedes","interface":"br-lan"} }
    -- odhcpd only sends v4 events
    if name == 'dhcp.ack' and #msg.name > 0 then
      setEntry(msg.name, msg.ip, leasetime, 'v4', byName4, byIP4)
    end
end

local function _getLeases(cmd, proto)
    local status = conn:call("dhcp", cmd, {})

    for _,intfv in pairs(status.device) do
        for _,lease in ipairs(intfv.leases) do
        if #lease.hostname > 0
        then
            if proto == 'v4' then
                setEntry(lease.hostname, lease.address, lease.valid, proto, byName4, byIP4)
            elseif proto == 'v6' and lease['ipv6-addr'] ~= nil then
                setEntry(lease.hostname, lease['ipv6-addr'][1].address, lease.valid, proto, byName6, byIP6)
            end
        end
      end
    end
end

local function getLeases()
    _getLeases("ipv4leases", 'v4')
    _getLeases("ipv6leases", 'v6')
end

local function _expireLeases(proto, byName, byIP)
    now = os.time()

    for k,v in pairs(byName) do
        if v.expire < now then
            delEntry(k, v.ip, proto, byName, byIP)
        end
    end
end

local function expireLeases()
    _expireLeases('v4', byName4, byIP4)
    _expireLeases('v6', byName6, byIP6)
end

local interval = 60*1000 -- milliseconds

local timer
local function maintenance()
    -- print("maint")
    getLeases()
    expireLeases()
    timer:set(interval)
    collectgarbage()
    collectgarbage()
end
timer = uloop.timer(maintenance)
timer:set(interval)

local sub = {
  notify = function(msg,name)
    handleEvent(msg, name)
  end,
}

conn:subscribe("dhcp", sub)

getLeases()

uloop.run()

-- Close connection
conn:close()
collectgarbage()
collectgarbage()
