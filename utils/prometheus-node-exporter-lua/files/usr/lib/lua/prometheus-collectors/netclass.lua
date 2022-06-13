local ubus = require "ubus"

-- reference/further reading:
-- - node_exporter netclass_linux (upstream metrics): https://github.com/prometheus/node_exporter/blob/master/collector/netclass_linux.go
-- - relevant sysfs files: https://github.com/prometheus/procfs/blob/5f46783c017ef6a934fc8cfa6d1a2206db21401b/sysfs/net_class.go#L121
-- - get devices / read files: https://github.com/openwrt/packages/blob/openwrt-21.02/utils/prometheus-node-exporter-lua/files/usr/lib/lua/prometheus-collectors/snmp6.lua

local function get_devices() -- based on hostapd_stations.lua
  local u = ubus.connect()
  local status = u:call("network.device", "status", {})
  local devices = {}

  for dev, dev_table in pairs(status) do
    table.insert(devices, dev)
  end
  return devices
end

local function load(device, file) -- load a single sysfs file, trim trailing newline, return nil on error
  local success, data = pcall(function () return string.gsub(get_contents("/sys/class/net/" .. device .. "/" .. file), "\n$", "") end)
  if success then
    return data
  else
    return nil
  end
end

local function file_gauge(name, device, file)
  local value = load(device, file)
  if value ~= nil then
    metric("node_network_" .. name, "gauge", {device = device}, tonumber(value))
  end
end

local function file_counter(name, device, file)
  local value = load(device, file)
  if value ~= nil then
    metric("node_network_" .. name, "counter", {device = device}, tonumber(value))
  end
end

local function get_metric(device)
  local address = load(device, "address")
  local broadcast = load(device, "broadcast")
  local duplex = load(device, "duplex")
  local operstate = load(device, "operstate")
  local ifalias = load(device, "ifalias")
  metric("node_network_info", "gauge", {device = device, address = address, broadcast = broadcast, duplex = duplex, operstate = operstate, ifalias = ifalias}, 1)
  file_gauge("address_assign_type", device, "addr_assign_type")
  file_gauge("carrier", device, "carrier")
  file_counter("carrier_changes_total", device, "carrier_changes")
  file_counter("carrier_up_changes_total", device, "carrier_up_count")
  file_counter("carrier_down_changes_total", device, "carrier_down_count")
  file_gauge("device_id", device, "dev_id")
  file_gauge("dormant", device, "dormant")
  file_gauge("flags", device, "flags")
  file_gauge("iface_id", device, "ifindex")
  file_gauge("iface_link", device, "iflink")
  file_gauge("iface_link_mode", device, "link_mode")
  file_gauge("mtu_bytes", device, "mtu")
  file_gauge("name_assign_type", device, "name_assign_type")
  file_gauge("net_dev_group", device, "netdev_group")
  file_gauge("transmit_queue_length", device, "tx_queue_len")
  file_gauge("protocol_type", device, "type")
  local speed = load(device, "speed")
  if speed ~= nil and tonumber(speed) >= 0 then
    metric("node_network_speed_bytes", "gauge", {device = device}, tonumber(speed)*1000*1000/8)
  end
end

local function scrape()
  for _, devicename in ipairs(get_devices()) do
    get_metric(devicename)
  end
end

return { scrape = scrape }
