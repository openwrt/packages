#!/usr/bin/lua

--[[
Mini-MWAN Daemon
Manages multi-WAN failover and load balancing
]]--

-- Conditionally load OpenWRT-specific dependencies
-- In test mode, these will be mocked via dependency injection
local uci, nixio, json, ubus, uloop
if not os.getenv("MINI_MWAN_TEST_MODE") then
  uci = require("uci")
  nixio = require("nixio")
  json = require("cjson")
  ubus = require("ubus")
  uloop = require("uloop")
else
  -- Test mode: use standard JSON if available, or it will be mocked
  local ok, cjson = pcall(require, "cjson")
  json = ok and cjson or {
    decode = function(str)
      error("JSON decoder not available - please install lua-cjson or mock it")
    end
  }
end

-- Configuration
local LOG_FILE = "/var/log/mini-mwan.log"

-- Persistent interface state (survives config reloads)
local interface_state = {}

-- Global state for ubus (shared across work cycles)
local current_status = {
  mode = "unknown",
  timestamp = 0,
  check_interval = 0,
  interfaces = {}
}

-- Global ubus connection moved to deps table for better testability

-- Dependencies table (defaults to real implementations)
-- In production: uses real OpenWrt modules
-- In test mode: must be completely replaced via set_dependencies()
local deps = {
  exec = function(cmd)
    local handle = io.popen(cmd)
    if not handle then return nil, "Failed to execute command" end
    local output = handle:read("*a")
    handle:close()
    return output
  end,
  log = function(msg, priority)
    nixio.syslog(priority, msg)
  end,
  sleep = function(seconds)
    nixio.nanosleep(seconds)
  end,
  time = os.time,
  open_file = io.open,
  uci_cursor = function()
    return uci.cursor()
  end,
  ubus_connect = function()
    return ubus.connect()
  end,
  uloop_init = function()
    return uloop.init()
  end,
  uloop_timer = function(callback)
    return uloop.timer(callback)
  end,
  uloop_run = function()
    return uloop.run()
  end
}

-- Allow dependency injection for testing
local function set_dependencies(new_deps)
  for k, v in pairs(new_deps) do
    deps[k] = v
  end
  -- Reset connection to force fresh connection with new deps
  deps.ubus_conn = nil
end

-- Logging function
-- Uses syslog for centralized logging (standard on OpenWRT)
local function log(msg, priority)
  priority = priority or "info"
  deps.log(msg, priority)
end

-- Execute read-only system probe (ping, ubus, ip route show, etc.)
-- Logged at debug level (7) - only visible when audit_log_level >= 7
local function system_probe(cmd)
  log(string.format("Probe: %s", cmd), "debug")  -- debug
  return deps.exec(cmd)
end

-- Execute state-changing system intervention (ip route add/replace/delete)
-- Logged at notice level (5) - important to track configuration changes
local function system_intervention(cmd)
  log(string.format("Intervention: %s", cmd), "notice")  -- notice
  return deps.exec(cmd)
end

-- Ping check function through specific interface
local function check_ping(target, count, timeout, device)
  count = count or 3
  timeout = timeout or 2

  -- Ping through specific interface using source routing
    -- Use -I to specify interface
  local deadline = (count * timeout) + 2
  local cmd = string.format("ping -I %s -c %d -W %d -w %d %s 2>&1", device, count, timeout, deadline, target)
  local output = system_probe(cmd)

  if not output then
    log(string.format("Ping failed: no output from command: %s", cmd), "err")  -- err
    return false, 0
  end

  -- Parse ping statistics
  local received = output:match("(%d+) packets received")
  if not received then
    log(string.format("Ping failed: could not parse output: %s", cmd), "err")
    return false, 0
  end

  if tonumber(received) > 0 then
    -- Parse average latency
    local avg_latency = output:match("min/avg/max[^=]+=.-/(.-)/")
    log(string.format("Ping successful: %s %s", target, avg_latency), "debug")
    return true, avg_latency
  end

  log(string.format("Ping failed: 0 packets received to %s via %s", target, device), "debug")
  return false, 0
end

-- Check if interface exists and is UP
-- Returns: (does_exist: boolean, is_up: boolean)
local function check_interface_is_up(iface)
  local cmd = string.format("ip addr show dev %s 2>/dev/null", iface)
  local output = system_probe(cmd)

  if not output then
    log(string.format("Failed to start ip addr show for iface: %s", iface), "err")
    return false, false  -- some serious problem - binary not found or so
  end

  if output:match("does not exist") then
    log(string.format("Device does not exist: %s", iface), "notice")
    return false, false  -- Device doesn't exist
  end

  -- Check if interface has UP flag
  -- Example: "3: wan: <BROADCAST,MULTICAST,UP,LOWER_UP>"
  if output:match("<[^>]*UP[^>]*>") then
    return true, true  -- Exists and is UP
  end

  return true, false  -- Exists but is DOWN
end

-- Get network statistics for interface (TX/RX bytes)
local function get_interface_stats(device)
  if not device or device == "" then
    return "0", "0"
  end

  -- Helper function to read a single stat file
  local function read_stat(stat_name)
    local path = string.format("/sys/class/net/%s/statistics/%s", device, stat_name)
    local file = deps.open_file(path, "r")
    if file then
      local content = file:read("*l") -- Read one line, automatically strips newline
      file:close()
      if content and content ~= "" then
        return content
      end
    end
    return "0"
  end

  local rx_bytes = read_stat("rx_bytes")
  local tx_bytes = read_stat("tx_bytes")

  return rx_bytes, tx_bytes
end

-- Probe all gateways from network dump (call once per cycle)
-- Returns device -> gateway map for O(1) lookups
-- P2P interfaces and interfaces without gateways will not be in the map
local function probe_all_gateways()
  -- Use libubus directly instead of shelling out to ubus binary
  -- conn is either initialized by register_ubus() or we get it from deps
  if not deps.ubus_conn then
    deps.ubus_conn = deps.ubus_connect()
  end

  log("Probe: ubus call network.interface dump", "debug")
  local data = deps.ubus_conn:call("network.interface", "dump", {})

  local gateway_map = {}

  if not data then
    log("Failed to call network.interface dump via ubus", "err")
    return gateway_map
  end

  -- data.interface is already a Lua table from libubus (no JSON parsing needed)
  if data.interface then
    for _, iface in ipairs(data.interface) do
      if iface.l3_device and iface.route then
        -- Look for default route (target 0.0.0.0, mask 0)
        for _, route in ipairs(iface.route) do
          if route.target == "0.0.0.0" and route.mask == 0 and route.nexthop then
            gateway_map[iface.l3_device] = route.nexthop
            break
          end
        end
      end
    end
  end

  return gateway_map
end

-- Detect if interface is point-to-point (VPN, PPP, tunnel) or shared medium (ethernet)
-- Point-to-point interfaces have POINTOPOINT flag set in ip link output
local function detect_point_to_point(device)
  if not device or device == "" then
    return false
  end

  local cmd = string.format("ip link show dev %s 2>/dev/null", device)
  local output = system_probe(cmd)

  if not output or output == "" then
    return false
  end

  -- Check for POINTOPOINT flag (note: uppercase in kernel output)
  return output:match("POINTOPOINT") ~= nil
end

-- Check if interface should be marked as degraded
-- Reads from config (name, device), reads/mutates state (point_to_point, gateway, degraded, degraded_reason)
local function check_degradation(iface_cfg, iface_state)
  -- Reset degradation first
  iface_state.degraded = 0
  iface_state.degraded_reason = ""

  -- Check 1: Regular interface without gateway (DHCP not complete)
  if not iface_state.point_to_point and (not iface_state.gateway or iface_state.gateway == "") then
    iface_state.degraded = 1
    iface_state.degraded_reason = "no_gateway"
    log(string.format("%s: DEGRADED - Regular interface missing gateway (DHCP incomplete?)",
                     iface_cfg.device or ""), "warning")  -- warning
    return iface_state
  end

  -- Check 2: IPv6 detection (application not compatible with IPv6)
  if iface_cfg.device and iface_cfg.device ~= "" then
    local cmd = string.format("ip -6 addr show dev %s 2>/dev/null", iface_cfg.device)
    local output = system_probe(cmd)

    -- Check if output contains global IPv6 addresses
    if output and output:match("inet6.*scope global") then
      iface_state.degraded = 1
      iface_state.degraded_reason = "ipv6_detected"
      log(string.format("%s: DEGRADED - IPv6 address detected (not supported)",
              iface_cfg.device), "warning")  -- warning
      return iface_state
    end
  end
  return iface_state
end

-- It could happen that there are more than one route with this interface
-- one of legitimate reasons - reconfiguration (and restart) of mini-mwan. previous instance
-- is usually terminated by LuCI and restarted. therefore there will be a leftover route from previous run
-- and we need to delete it
local function delete_all_routes_except(iface_cfg)
  local output = system_probe(string.format("ip route show default dev %s", iface_cfg.device))

  if output and output ~= "" then
    local routes = {}
    for line in output:gmatch("[^\r\n]+") do
      table.insert(routes, line)
    end

    for i = 1, #routes do
      local line = routes[i]
      local metric = tonumber(line:match("metric (%d+)"))
      if metric then
        -- Delete all routes except that one which we added with a given metric
        if metric ~= iface_cfg.metric then
          system_intervention(string.format("ip route delete default dev %s metric %s 2>/dev/null",
            iface_cfg.device, metric))
        end
      else
        system_intervention(string.format("ip route delete default dev %s 2>/dev/null",
          iface_cfg.device))
      end
    end
  end
end

local function replace_default_gw(iface_cfg, iface_state)
  if iface_state.gateway and iface_state.gateway ~= "" then
    -- Regular interface with gateway (e.g., ethernet)
    system_intervention(string.format("ip route replace default via %s dev %s metric %d",
                    iface_state.gateway, iface_cfg.device, iface_cfg.metric))
  else
    -- Point-to-point interface without gateway (e.g., VPN tunnel)
    system_intervention(string.format("ip route replace default dev %s metric %d",
                    iface_cfg.device, iface_cfg.metric))
  end
end

-- Add/update default route for an interface
-- Reads config (metric), reads state (gateway)
-- Note: Only called for usable interfaces (degraded ones already filtered by classify_interfaces)
local function set_route(iface_cfg, iface_state)
  -- Step 1: Add our route with the correct metric (ensures valid route exists)
  replace_default_gw(iface_cfg, iface_state)
  -- Step 2: Clean up duplicate routes for this device (created by external tools or by previous invocations of mini-mwan)
  delete_all_routes_except(iface_cfg)
end

-- Load configuration from UCI (immutable)
local function load_config()
  deps.uci_cursor():load("mini-mwan")

  local config = {
    enabled = deps.uci_cursor():get("mini-mwan", "settings", "enabled") == "1",
    mode = deps.uci_cursor():get("mini-mwan", "settings", "mode") or "failover",
    check_interval = tonumber(deps.uci_cursor():get("mini-mwan", "settings", "check_interval")) or 30,
    log_level = deps.uci_cursor():get("mini-mwan", "settings", "audit") or "emerg",
    interfaces = {}
  }

  -- Load all interface configurations (config only, no state)
  -- Section name is the device name (e.g., config interface 'eth0')
  deps.uci_cursor():foreach("mini-mwan", "interface", function(section)
    local iface_cfg = {
      device = section.device,
      metric = tonumber(section.metric) or 10,
      weight = tonumber(section.weight) or 3,
      ping_target = section.ping_target,
      ping_count = tonumber(section.ping_count) or 3,
      ping_timeout = tonumber(section.ping_timeout) or 2
    }

    table.insert(config.interfaces, iface_cfg)
  end)

  return config
end


local function save_interface_state(device, iface_state)
  iface_state.last_check = deps.time()
  -- Save state
  interface_state[device] = {
    does_exist = iface_state.does_exist,
    is_up = iface_state.is_up,
    status_since = iface_state.status_since,
    latency = iface_state.latency,
    last_check = iface_state.last_check,
    degraded = iface_state.degraded,
    degraded_reason = iface_state.degraded_reason,
  }
  return iface_state
end

local function transition_iface_down(device, iface_state)
  if iface_state.is_up then
    log(string.format("%s: Interface DOWN (connectivity lost)", device or "unknown"), "info")
    iface_state.latency = "?"
    iface_state.is_up = false
    iface_state.status_since = deps.time()
  end
  return iface_state
end

local function transition_iface_up(device, iface_state)
  if not iface_state.is_up then
    log(string.format("%s: Interface UP (latency: %s ms)", device or "unknown", iface_state.latency or "?"), "info")
    iface_state.is_up = true
    iface_state.status_since = deps.time()
  end
  return iface_state
end

-- Update interface status with timestamp tracking
-- Reads config (enabled, device, ping_target, ping_count, ping_timeout)
-- Mutates state (does_exist, is_up, status_since, last_check, latency)
local function update_interface_status(iface_cfg, iface_state)

  -- Check if interface exists and is UP
  local does_exist, is_up = check_interface_is_up(iface_cfg.device)

  -- Log interface disappearance/reappearance
  if iface_state.does_exist and not does_exist then
    log(string.format("%s: Interface DISAPPEARED (USB dongle removed? tunnel down?)", iface_cfg.device), "warning")
  elseif not iface_state.does_exist and does_exist then
    log(string.format("%s: Interface APPEARED (device reconnected)", iface_cfg.device), "info")
  end

  iface_state.does_exist = does_exist;

  if not is_up then
    return save_interface_state(iface_cfg.device, transition_iface_down(iface_cfg.device, iface_state))
  end

  -- Interface exists and is UP, now ping through it to check connectivity
  -- Note: gateway can be nil for point-to-point interfaces (e.g., VPN tunnels)
  local alive, latency = check_ping(iface_cfg.ping_target, iface_cfg.ping_count, iface_cfg.ping_timeout, iface_cfg.device)
    if alive then
    iface_state.latency = latency
    return save_interface_state(iface_cfg.device, transition_iface_up(iface_cfg.device, iface_state))
  else
    return save_interface_state(iface_cfg.device, transition_iface_down(iface_cfg.device, iface_state))
  end
end

-- Probe state based on config (mutable, ephemeral)
-- Discovers gateways, checks degradation, probes interface status (up/down, ping, latency)
local function probe_state(config)
  local state = {
    interfaces = {}
  }

  -- Probe all gateways once per cycle (single ubus call)
  local gateway_map = probe_all_gateways()

  for _, iface_cfg in ipairs(config.interfaces) do
    -- Restore persistent state if it exists
    local saved_state = interface_state[iface_cfg.device] or {}

    -- State contains ONLY mutable runtime fields
    local iface_state = {
      does_exist = saved_state.does_exist or false,
      is_up = saved_state.is_up or false,
      status_since = saved_state.status_since,
      latency = saved_state.latency or "?",
      -- Discover gateway from network dump (O(1) lookup)
      gateway = gateway_map[iface_cfg.device],
      degraded = saved_state.degraded or 0,
      degraded_reason = saved_state.degraded_reason or "",
      last_check = saved_state.last_check,
      -- Detect interface type (MUST be done before gateway/degradation checks)
      point_to_point = detect_point_to_point(iface_cfg.device)
    }

    check_degradation(iface_cfg, iface_state)

    -- Probe actual interface status (up/down, ping, latency)
    update_interface_status(iface_cfg, iface_state)

    table.insert(state.interfaces, iface_state)
  end

  return state
end

-- Write view (presentation for LuCI/status display)
-- Merges config + state into a single view file (write and forget)
-- Update global status for ubus (replaces write_view)
local function update_status(config, state)
  -- Update global status object that will be served via ubus
  current_status.mode = config.mode
  current_status.timestamp = deps.time()
  current_status.check_interval = config.check_interval

  -- Build interfaces array
  current_status.interfaces = {}
  for i, iface_cfg in ipairs(config.interfaces) do
    local iface_state = state.interfaces[i]

    -- Get current network statistics
    local rx_bytes, tx_bytes = get_interface_stats(iface_cfg.device)

    -- Create interface status object
    table.insert(current_status.interfaces, {
      device = iface_cfg.device or "",
      ping_target = iface_cfg.ping_target or "",
      does_exist = iface_state.does_exist,
      is_up = iface_state.is_up,
      degraded = iface_state.degraded,
      degraded_reason = iface_state.degraded_reason or "",
      status_since = iface_state.status_since or "",
      last_check = iface_state.last_check or "",
      latency = iface_state.latency,
      gateway = iface_state.gateway or "",
      rx_bytes = tonumber(rx_bytes) or 0,
      tx_bytes = tonumber(tx_bytes) or 0
    })
  end
end

-- Remove or demote default routes for interfaces not managed by mini-mwan
local function cleanup_unmanaged_routes(config)
  -- Build list of managed devices
  local managed_devices = {}
  for _, iface in ipairs(config.interfaces) do
    if iface.device and iface.device ~= "" then
      managed_devices[iface.device] = true
    end
  end

  -- Get all current default routes
  local output = system_probe("ip route show default")
  if not output or output == "" then
    return
  end

  -- Parse each default route and handle unmanaged ones
  for line in output:gmatch("[^\r\n]+") do
    -- Extract device from route line
    -- Format: "default via X.X.X.X dev eth0 metric N" or "default dev eth0 metric N"
    local device = line:match("dev%s+(%S+)")

    if device and not managed_devices[device] then
      local via = line:match("via%s+(%S+)")
      if via then
        system_intervention(string.format("ip route delete default via %s dev %s", via, device))
        system_intervention(string.format("ip route replace default via %s dev %s metric 999", via, device))
      else
        system_intervention(string.format("ip route delete default dev %s", device))
        system_intervention(string.format("ip route replace default dev %s metric 999", device))
      end
    end
  end
end

-- Classify interfaces into usable (for routing) and unusable
-- Returns {usable = {{cfg, state}, ...}, unusable = {{cfg, state}, ...}}
local function classify_interfaces(config, state)

  local usable = {}
  local unusable = {}

  for i, iface_cfg in ipairs(config.interfaces) do
    local iface_state = state.interfaces[i]

    -- we don't touch routes of degraded interfaces
    if iface_state.degraded == 0 then
      if iface_state.is_up then
        -- Interface is up and has connectivity (ping succeeded)
        table.insert(usable, {cfg = iface_cfg, state = iface_state})
      else
        -- Interface is up but no connectivity (ping failed)
        table.insert(unusable, {cfg = iface_cfg, state = iface_state})
      end
    end
  end

  return {usable = usable, unusable = unusable}
end

-- Handle unusable interfaces by setting them to metric 900
-- This keeps them routable for ping testing but prevents them from being used for traffic
local function deprioritize_unusable_interfaces(unusable)
  for _, iface in ipairs(unusable) do
    -- Use 'replace' instead of 'add' to handle cases where route already exists
    -- But we still need to delete first, so that eventually all duplicates get removed
    if iface.state.gateway and iface.state.gateway ~= "" then
      system_intervention(string.format("ip route delete default dev %s", iface.cfg.device))
      system_intervention(string.format("ip route replace default via %s dev %s metric 900",
        iface.state.gateway, iface.cfg.device))
    else
      system_intervention(string.format("ip route delete default dev %s", iface.cfg.device))
      system_intervention(string.format("ip route replace default dev %s metric 900", iface.cfg.device))
    end
  end
end

-- Failover mode logic
-- Receives only usable interfaces (already classified)
-- Sets routes with configured metrics - kernel handles priority automatically
local function set_routes_for_failover(usable_ifaces)
  -- Set all routes with their configured metrics
  -- Kernel routing table automatically uses lowest metric as primary
  for _, iface in ipairs(usable_ifaces) do
    set_route(iface.cfg, iface.state)
  end
end

-- Multi-uplink mode logic with multipath routing
-- Receives only usable interfaces (already classified)
-- Creates a single multipath route with weighted load balancing
local function set_route_multiuplink(usable_ifaces)
  -- Check if any interfaces are available
  if #usable_ifaces == 0 then
    log("No active WAN connections!", "warning")  -- warning
    return
  end

  -- Build multipath route command
  -- ip route replace default nexthop via GW1 dev DEV1 weight W1 nexthop dev DEV2 weight W2
  local route_parts = {}
  for _, iface in ipairs(usable_ifaces) do
    local nexthop
    if iface.state.gateway and iface.state.gateway ~= "" then
      nexthop = string.format("nexthop via %s dev %s weight %d",
        iface.state.gateway, iface.cfg.device, iface.cfg.weight)
    else
      nexthop = string.format("nexthop dev %s weight %d", iface.cfg.device, iface.cfg.weight)
    end
    table.insert(route_parts, nexthop)
  end

  local multipath_cmd = "ip route replace default " .. table.concat(route_parts, " ")
  system_intervention(multipath_cmd)
end

local function at_least_two_wans_configured(config)
  local wan1_configured = config.interfaces[1] and config.interfaces[1].device and config.interfaces[1].device ~= ""
  local wan2_configured = config.interfaces[2] and config.interfaces[2].device and config.interfaces[2].device ~= ""
  return wan1_configured and wan2_configured
end

local function work(config)
  -- Probe mutable state based on config (discovers gateway, checks degradation, pings)
  local state = probe_state(config)

  -- Cleanup routes from interfaces no longer managed
  cleanup_unmanaged_routes(config)

  -- Classify interfaces into usable (for routing) and unusable
  local classified = classify_interfaces(config, state)

  -- Handle unusable interfaces (set metric 900 so pings still work)
  deprioritize_unusable_interfaces(classified.unusable)

  -- Run appropriate routing mode with only usable interfaces
  if config.mode == "failover" then
    set_routes_for_failover(classified.usable)
  elseif config.mode == "multiuplink" then
    set_route_multiuplink(classified.usable)
  end

  -- Update status (merges config + state for ubus)
  update_status(config, state)
end

-- Work timer callback (replaces while loop)
local work_timer
local function work_cycle()
  -- Load immutable config from UCI
  local config = load_config()

  -- Update log level filter after config reload
  nixio.setlogmask(config.log_level)

  if config.enabled then
    if at_least_two_wans_configured(config) then
      work(config)
    else
      log("Both WAN interfaces must be configured. Refusing to work!", "err")  -- err
    end
  end

  -- Reschedule timer with current check_interval
  work_timer:set(config.check_interval * 1000)  -- milliseconds
end

-- ubus method handlers
local ubus_methods = {
  ["mini-mwan"] = {
    status = {
      function(req, msg)
        -- Return current status as JSON
        deps.ubus_conn:reply(req, current_status)
      end,
      {}  -- No parameters required
    }
  }
}

-- Register ubus methods
local function register_ubus()
  -- Connect to ubus
  deps.ubus_conn = deps.ubus_connect()
  if not deps.ubus_conn then
    log("Failed to connect to ubus", "err")
    return false
  end

  -- Register ubus methods
  deps.ubus_conn:add(ubus_methods)
  log("Registered ubus object: mini-mwan", "notice")
  return true
end

-- Run work cycle in uloop event loop
local function run_event_loop()
  -- Initialize uloop event loop
  deps.uloop_init()

  -- Create work timer
  work_timer = deps.uloop_timer(work_cycle)

  -- Start first work cycle immediately
  work_timer:set(100)  -- 100ms delay for initial run

  -- Run event loop
  deps.uloop_run()

  -- Cleanup on exit
  if deps.ubus_conn then
    deps.ubus_conn:close()
  end
end

-- Main daemon entry point
local function main()
  -- Initialize syslog
  nixio.openlog("mini-mwan")

  log("Mini-MWAN daemon starting", "notice")  -- notice

  -- Register ubus interface
  if not register_ubus() then
    return
  end

  -- Run event loop
  run_event_loop()
end

-- Export functions for testing
if os.getenv("MINI_MWAN_TEST_MODE") then
  return {
    -- in Java, we call it package-private
    -- but here in lua, we export methods for testing
    set_dependencies = set_dependencies,
    probe_all_gateways = probe_all_gateways,
    detect_point_to_point = detect_point_to_point,
    check_degradation = check_degradation,
    set_route = set_route,
    check_ping = check_ping,
    check_interface_is_up = check_interface_is_up,
    set_routes_for_failover = set_routes_for_failover,
    set_route_multiuplink = set_route_multiuplink,
    load_config = load_config,
    probe_state = probe_state,
    update_interface_status = update_interface_status,
    classify_interfaces = classify_interfaces,
    deprioritize_unusable_interfaces = deprioritize_unusable_interfaces,
    work = work,
    log = log,
    register_ubus = register_ubus
  }
else
  -- Normal operation - run daemon
  main()
end
