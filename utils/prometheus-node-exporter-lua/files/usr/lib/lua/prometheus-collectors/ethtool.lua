local ethtool = require "ethtool"

local pattern_device = "^%s*([^%s:]+):"
local pattern_metric = "_*[^0-9A-Za-z_]+_*"

local metric_fqnames = {
  rx_bytes = "node_ethtool_received_bytes_total",
  rx_dropped = "node_ethtool_received_dropped_total",
  rx_errors = "node_ethtool_received_errors_total",
  rx_packets = "node_ethtool_received_packets_total",
  tx_bytes = "node_ethtool_transmitted_bytes_total",
  tx_errors = "node_ethtool_transmitted_errors_total",
  tx_packets = "node_ethtool_transmitted_packets_total",
  -- link info
  supported_port = "node_network_supported_port_info",
  supported_speed = "node_network_supported_speed_bytes",
  supported_autonegotiate = "node_network_autonegotiate_supported",
  supported_pause = "node_network_pause_supported",
  supported_asymmetricpause = "node_network_asymmetricpause_supported",
  advertised_speed = "node_network_advertised_speed_bytes",
  advertised_autonegotiate = "node_network_autonegotiate_advertised",
  advertised_pause = "node_network_pause_advertised",
  advertised_asymmetricpause = "node_network_asymmetricpause_advertised",
  autonegotiate = "node_network_autonegotiate",
}
local metric_replacement_words = {
  rx = "received",
  tx = "transmitted",
}

local function get_devices()
  local devices = {}
  for line in io.lines("/proc/net/dev") do
    local dev = string.match(line, pattern_device)
    if dev then
      table.insert(devices, dev)
    end
  end
  return devices
end

local function replace_words(metric)
  return string.gsub(metric, "(%a+)", function(word)
    local replacement = metric_replacement_words[word]
    if replacement then
      return replacement
    end
    return word
  end)
end

local function build_ethtool_fqname(metric)
  local metricName = metric:gsub(pattern_metric, "_")
  metricName = metricName:lower():gsub("^[%s_]+", "")
  metricName = replace_words(metricName)
  return "node_ethtool_" .. metricName
end

local function scrape()
  local eth = ethtool.open()
  local metrics = {}
  for _, dev in ipairs(get_devices()) do
    local stats = eth:statistics(dev)
    if stats then
      for m_name, m_value in pairs(stats) do
        fqname = metric_fqnames[m_name]
        if fqname == nil then
          fqname = build_ethtool_fqname(m_name)
          metric_fqnames[m_name] = fqname
        end
        local m = metrics[fqname]
        if m == nil then
          m = metric(fqname, "untyped")
          metrics[fqname] = m
        end
        m({ device = dev }, m_value)
      end
    end
  end
  eth:close()
end

return { scrape = scrape }
