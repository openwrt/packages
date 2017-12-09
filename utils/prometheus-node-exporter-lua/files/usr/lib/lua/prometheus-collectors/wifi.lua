local ubus = require "ubus"
local iwinfo = require "iwinfo"

local function scrape()
  local metric_wifi_network_quality = metric("wifi_network_quality","gauge")
  local metric_wifi_network_bitrate = metric("wifi_network_bitrate","gauge")
  local metric_wifi_network_noise = metric("wifi_network_noise","gauge")
  local metric_wifi_network_signal = metric("wifi_network_signal","gauge")

  local metric_wifi_station_signal = metric("wifi_station_signal","gauge")
  local metric_wifi_station_tx_packets = metric("wifi_station_tx_packets","gauge")
  local metric_wifi_station_rx_packets = metric("wifi_station_rx_packets","gauge")

  local u = ubus.connect()
  local status = u:call("network.wireless", "status", {})

  for dev, dev_table in pairs(status) do
    for _, intf in ipairs(dev_table['interfaces']) do
      local ifname = intf['ifname']
      local iw = iwinfo[iwinfo.type(ifname)]
      local labels = {
        channel = iw.channel(ifname),
        ssid = iw.ssid(ifname),
        bssid = iw.bssid(ifname),
        mode = iw.mode(ifname),
        ifname = ifname,
        country = iw.country(ifname),
        frequency = iw.frequency(ifname),
        device = dev,
      }

      local qc = iw.quality(ifname) or 0
      local qm = iw.quality_max(ifname) or 0
      local quality = 0
      if qc > 0 and qm > 0 then
        quality = math.floor((100 / qm) * qc)
      end

      metric_wifi_network_quality(labels, quality)
      metric_wifi_network_noise(labels, iw.noise(ifname) or 0)
      metric_wifi_network_bitrate(labels, iw.bitrate(ifname) or 0)
      metric_wifi_network_signal(labels, iw.signal(ifname) or -255)

      local assoclist = iw.assoclist(ifname)
      for mac, station in pairs(assoclist) do
        local labels = {
          ifname = ifname,
          mac = mac,
        }
        metric_wifi_station_signal(labels, station.signal)
        metric_wifi_station_tx_packets(labels, station.tx_packets)
        metric_wifi_station_rx_packets(labels, station.rx_packets)
      end
    end
  end
end

return { scrape = scrape }
