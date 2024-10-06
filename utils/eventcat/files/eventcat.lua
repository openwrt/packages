#!/usr/bin/lua

local uci = require("uci").cursor()
local uloop = require("uloop")
local nixio = require("nixio")

uloop.init()

-- Parse time strings with units like watchcat did
local function parse_time(time_str)
    if not time_str then return nil end
    local num, unit = time_str:match("^(%d+)([smhdSMHD]?)$")
    num = tonumber(num)
    if not num then
        nixio.syslog("err", "EventCat: Invalid time value '" .. tostring(time_str) .. "'")
        return nil
    end

    unit = unit:lower()
    if unit == "s" or unit == "" then
        return num
    elseif unit == "m" then
        return num * 60
    elseif unit == "h" then
        return num * 3600
    elseif unit == "d" then
        return num * 86400
    else
        nixio.syslog("err", "EventCat: Invalid time unit '" .. tostring(unit) .. "' in '" .. tostring(time_str) .. "'")
        return nil
    end
end

-- Read configuration from UCI
local config = {}
local success, err = pcall(function()
    uci:foreach("eventcat", "eventcat", function(s)
        for k, v in pairs(s) do
            config[k] = v
        end
    end)
end)

if not success then
    nixio.syslog("err", "EventCat: Error reading UCI configuration: " .. tostring(err))
    os.exit(1)
end

-- Set defaults and parse configurations
local mode = config.mode or "connectivity_check"
local action = config.action or "reboot"
local period = parse_time(config.period) or 300
local interface = config.interface
local hosts = {}

if config.host then
    if type(config.host) == "table" then
        hosts = config.host
    else
        hosts = {config.host}
    end
else
    nixio.syslog("err", "EventCat: Error host is required: " .. tostring(err))
    os.exit(1)
end

local script = config.script
local address_family = config.address_family or "ipv4"
local ping_interval = parse_time(config.ping_interval) or 30
local ping_timeout = parse_time(config.ping_timeout) or 5
local event_triggered = config.event_triggered == '1'

-- Supported actions here
local function perform_action()
    if action == "reboot" then
        nixio.syslog("info", "EventCat: Rebooting system")
        os.execute("reboot")
    elseif action == "restart_interface" and interface then
        nixio.syslog("info", "EventCat: Restarting interface " .. interface)
        os.execute("/sbin/ifdown " .. interface)
        os.execute("/sbin/ifup " .. interface)
    elseif action == "run_script" and script then
        nixio.syslog("info", "EventCat: Running script " .. script)
        os.execute(script)
    else
        nixio.syslog("err", "EventCat: Invalid action or missing parameters")
    end
end

local last_successful_time = os.time()

-- Checks the connectivity with a ping
local function check_connectivity()
    local connected = false
    for _, host in ipairs(hosts) do
        local ping_cmd = string.format("ping -c 1 -W %d %s > /dev/null 2>&1", ping_timeout, host)
        local ret = os.execute(ping_cmd)
        if ret == 0 then
            connected = true
            break
        end
    end

    if connected then
        last_successful_time = os.time()
    else
        local time_since_success = os.time() - last_successful_time
        if time_since_success >= period then
            nixio.syslog("info", "EventCat: Host down longer than configured period. Taking action...")
            perform_action()
            -- Reset the timer
            last_successful_time = os.time()
        end
    end
end

local function schedule_timer(callback, interval)
    local timer
    timer = uloop.timer(function()
        callback()
        if timer then
            timer:set(interval * 1000)
        else
            nixio.syslog("err", "EventCat: Timer is nil, unable to set interval")
        end
    end)

    if timer then
        timer:set(interval * 1000)
    else
        nixio.syslog("err", "EventCat: Failed to initialize timer")
    end
end

-- Schedule connectivity checks and periodic action
if mode == "connectivity_check" then
    schedule_timer(check_connectivity, ping_interval)
end

if mode == "periodic" then
    schedule_timer(perform_action, period)
end

uloop.run()
