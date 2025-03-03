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

local function get_metric(device, metric_node_network)
  local address = load(device, "address")
  local broadcast = load(device, "broadcast")
  local duplex = load(device, "duplex")
  local operstate = load(device, "operstate")
  local ifalias = load(device, "ifalias")
  metric_node_network.info({device = device, address = address, broadcast = broadcast, duplex = duplex, operstate = operstate, ifalias = ifalias}, 1)
  local speed = tonumber(load(device, "speed"))
  if speed ~= nil and speed >= 0 then
    metric_node_network.speed_bytes({device = device}, speed*1000*1000/8)
  end
  local file_to_metric = {
    addr_assign_type   = "address_assign_type",
    carrier            = "carrier",
    carrier_changes    = "carrier_changes_total",
    carrier_up_count   = "carrier_up_changes_total",
    carrier_down_count = "carrier_down_changes_total",
    dev_id             = "device_id",
    dormant            = "dormant",
    flags              = "flags",
    ifindex            = "iface_id",
    iflink             = "iface_link",
    link_mode          = "iface_link_mode",
    mtu                = "mtu_bytes",
    name_assign_type   = "name_assign_type",
    netdev_group       = "net_dev_group",
    tx_queue_len       = "transmit_queue_length",
    type               = "protocol_type",
  }
  for file, metric in pairs(file_to_metric) do
    local value = tonumber(load(device, file))
    if value ~= nil then
      metric_node_network[metric]({device = device}, value)
    end
  end
end

local function scrape()
  local metric_node_network = {
    info                       = metric("node_network_info", "gauge"),
    address_assign_type        = metric("node_network_address_assign_type", "gauge"),
    carrier                    = metric("node_network_carrier", "gauge"),
    carrier_changes_total      = metric("node_network_carrier_changes_total", "counter"),
    carrier_up_changes_total   = metric("node_network_carrier_up_changes_total", "counter"),
    carrier_down_changes_total = metric("node_network_carrier_down_changes_total", "counter"),
    device_id                  = metric("node_network_device_id", "gauge"),
    dormant                    = metric("node_network_dormant", "gauge"),
    flags                      = metric("node_network_flags", "gauge"),
    iface_id                   = metric("node_network_iface_id", "gauge"),
    iface_link                 = metric("node_network_iface_link", "gauge"),
    iface_link_mode            = metric("node_network_iface_link_mode", "gauge"),
    mtu_bytes                  = metric("node_network_mtu_bytes", "gauge"),
    name_assign_type           = metric("node_network_name_assign_type", "gauge"),
    net_dev_group              = metric("node_network_net_dev_group", "gauge"),
    transmit_queue_length      = metric("node_network_transmit_queue_length", "gauge"),
    protocol_type              = metric("node_network_protocol_type", "gauge"),
    speed_bytes                = metric("node_network_speed_bytes", "gauge"),
  }
  for _, devicename in ipairs(get_devices()) do
    get_metric(devicename, metric_node_network)
  end
end

return { scrape = scrape }
