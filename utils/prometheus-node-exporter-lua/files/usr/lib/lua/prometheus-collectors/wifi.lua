local ubus = require "ubus"
local iwinfo = require "iwinfo"

local function scrape()
  local metric_wifi_radio_config = metric("wifi_radio_config","gauge")
  local metric_wifi_radio_channel = metric("wifi_radio_channel","gauge")
  local metric_wifi_network_config = metric("wifi_network_config","gauge")
  local metric_wifi_network_quality = metric("wifi_network_quality","gauge")
  local metric_wifi_network_bitrate = metric("wifi_network_bitrate","gauge")
  local metric_wifi_network_noise = metric("wifi_network_noise_dbm","gauge")
  local metric_wifi_network_signal = metric("wifi_network_signal_dbm","gauge")
  local metric_wifi_network_stations_total = metric("wifi_network_stations_total","gauge")

  local u = ubus.connect()
  local status = u:call("network.wireless", "status", {})

  for dev, dev_table in pairs(status) do
    local radio_config = dev_table['config']
    local radio_config_labels = {
      radio = dev,
      hwmode = radio_config['hwmode'],
      channel = radio_config['channel'],
      country = radio_config['country'],
    }
    local radio_labels = {
      radio = dev,
    }
    metric_wifi_radio_config(radio_config_labels, 1)
    metric_wifi_radio_channel(radio_labels, radio_config['channel'])

    for _, intf in ipairs(dev_table['interfaces']) do
      local ifname = intf['ifname']
      if ifname ~= nil then
        local iw = iwinfo[iwinfo.type(ifname)]
        local network_config_labels = {
          ssid = iw.ssid(ifname),
          bssid = string.lower(iw.bssid(ifname)),
          mode = iw.mode(ifname),
          ifname = ifname,
          radio = dev,
        }
        local network_labels = {
          ifname = ifname,
          radio = dev,
        }

        local qc = iw.quality(ifname) or 0
        local qm = iw.quality_max(ifname) or 0
        local quality = 0
        if qc > 0 and qm > 0 then
          quality = math.floor((100 / qm) * qc)
        end

        local stations = 0
        for _ in pairs(iw.assoclist(ifname)) do
          stations = stations + 1
        end

        metric_wifi_network_config(network_config_labels, 1)
        metric_wifi_network_quality(network_labels, quality)
        metric_wifi_network_noise(network_labels, iw.noise(ifname) or 0)
        metric_wifi_network_bitrate(network_labels, iw.bitrate(ifname) or 0)
        metric_wifi_network_signal(network_labels, iw.signal(ifname) or -255)
        metric_wifi_network_stations_total(network_labels, stations)
      end
    end
  end
end

return { scrape = scrape }
