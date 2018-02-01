local ubus = require "ubus"
local iwinfo = require "iwinfo"

local function scrape()
  local metric_wifi_station_signal = metric("wifi_station_signal","gauge")
  local metric_wifi_station_tx_packets = metric("wifi_station_tx_packets","gauge")
  local metric_wifi_station_rx_packets = metric("wifi_station_rx_packets","gauge")

  local u = ubus.connect()
  local status = u:call("network.wireless", "status", {})

  for dev, dev_table in pairs(status) do
    for _, intf in ipairs(dev_table['interfaces']) do
      local ifname = intf['ifname']
      local iw = iwinfo[iwinfo.type(ifname)]

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
