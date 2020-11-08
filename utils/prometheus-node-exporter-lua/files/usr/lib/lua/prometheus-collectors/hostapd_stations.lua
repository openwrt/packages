local ubus = require "ubus"
local bit32 = require "bit32"

local function get_wifi_interface_labels()
  local u = ubus.connect()
  local status = u:call("network.wireless", "status", {})
  local interfaces = {}

  for _, dev_table in pairs(status) do
    for _, intf in ipairs(dev_table['interfaces']) do
      local cfg = intf['config']

      -- Migrate this to ubus interface once it exposes all interesting labels
      local handle = io.popen("hostapd_cli -i " .. cfg['ifname'] .." status")
      local hostapd_status = handle:read("*a")
      handle:close()

      local hostapd = {}
      for line in hostapd_status:gmatch("[^\r\n]+") do
        local name, value = string.match(line, "(.+)=(.+)")
        if name == "phy" then
          hostapd["vif"] = value
        elseif name == "freq" then
          hostapd["freq"] = value
        elseif name == "channel" then
          hostapd["channel"] = value
        elseif name == "bssid[0]" then
          hostapd["bssid"] = value
        elseif name == "ssid[0]" then
          hostapd["ssid"] = value
        end
      end

      local labels = {
        vif = hostapd['vif'],
        ssid = hostapd['ssid'],
        bssid = hostapd['bssid'],
        encryption = cfg['encryption'], -- In a mixed scenario it would be good to know if A or B was used
        frequency = hostapd['freq'],
        channel = hostapd['channel'],
      }

      table.insert(interfaces, labels)
    end
  end

  return interfaces
end

local function scrape()
  local metric_hostapd_station_vht = metric("hostapd_station_vht", "gauge")
  local metric_hostapd_station_ht = metric("hostapd_station_ht", "gauge")
  local metric_hostapd_station_wmm = metric("hostapd_station_wmm", "gauge")
  local metric_hostapd_station_mfp = metric("hostapd_station_mfp", "gauge")

  local metric_hostapd_station_rx_packets = metric("hostapd_station_rx_packets", "counter")
  local metric_hostapd_station_rx_bytes = metric("hostapd_station_rx_bytes", "counter")
  local metric_hostapd_station_tx_packets = metric("hostapd_station_tx_packets", "counter")
  local metric_hostapd_station_tx_bytes = metric("hostapd_station_tx_bytes", "counter")

  local metric_hostapd_station_inactive_msec = metric("hostapd_station_inactive_msec", "counter")

  local metric_hostapd_station_signal = metric("hostapd_station_signal", "gauge")
  local metric_hostapd_station_connected_time = metric("hostapd_station_connected_time", "counter")

  local metric_hostapd_station_wpa = metric("hostapd_station_wpa", "gauge")
  local metric_hostapd_station_sae_group = metric("hostapd_station_sae_group", "gauge")

  local metric_hostapd_station_vht_capb_su_beamformee = metric("hostapd_station_vht_capb_su_beamformee", "gauge")
  local metric_hostapd_station_vht_capb_mu_beamformee = metric("hostapd_station_vht_capb_mu_beamformee", "gauge")

  local function evaluate_metrics(labels, vals)
    for k, v in pairs(vals) do
      if k == "flags" then
        if string.match(v, "[VHT]") then
          metric_hostapd_station_vht(labels, 1)
        end
        if string.match(v, "[HT]") then
          metric_hostapd_station_ht(labels, 1)
        end
        if string.match(v, "[WMM]") then
          metric_hostapd_station_wmm(labels, 1)
        end
        if string.match(v, "[MFP]") then
          metric_hostapd_station_mfp(labels, 1)
        end
      elseif k == "wpa" then
        metric_hostapd_station_wpa(labels, v)
      elseif k == "rx_packets" then
        metric_hostapd_station_rx_packets(labels, v)
      elseif k == "rx_bytes" then
        metric_hostapd_station_rx_bytes(labels, v)
      elseif k == "tx_packets" then
        metric_hostapd_station_tx_packets(labels, v)
      elseif k == "tx_bytes" then
        metric_hostapd_station_tx_bytes(labels, v)
      elseif k == "inactive_msec" then
        metric_hostapd_station_inactive_msec(labels, v)
      elseif k == "signal" then
        metric_hostapd_station_signal(labels, v)
      elseif k == "connected_time" then
        metric_hostapd_station_connected_time(labels, v)
      elseif k == "sae_group" then
        metric_hostapd_station_sae_group(labels, v)
      elseif k == "vht_caps_info" then
	      local caps = tonumber(string.gsub(v, "0x", ""), 16)
	      metric_hostapd_station_vht_capb_su_beamformee(labels, bit32.band(bit32.lshift(1, 12), caps) > 0 and 1 or 0)
	      metric_hostapd_station_vht_capb_mu_beamformee(labels, bit32.band(bit32.lshift(1, 20), caps) > 0 and 1 or 0)
      end
    end
  end

  for _, labels in ipairs(get_wifi_interface_labels()) do
    local vif = labels['vif']
    local handle = io.popen("hostapd_cli -i " .. vif .." all_sta")
    local all_sta = handle:read("*a")
    handle:close()

    local current_station = nil
    local current_station_values = {}

    for line in all_sta:gmatch("[^\r\n]+") do
      if string.match(line, "^%x[0123456789aAbBcCdDeE]:%x%x:%x%x:%x%x:%x%x:%x%x$") then
        if current_station ~= nil then
          labels.station = current_station
          evaluate_metrics(labels, current_station_values)
        end
        current_station = line
        current_station_values = {}
      else
        local name, value = string.match(line, "(.+)=(.+)")
        current_station_values[name] = value
      end
    end
    labels.station = current_station
    evaluate_metrics(labels, current_station_values)
  end
end

return { scrape = scrape }
