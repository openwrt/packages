#!/usr/bin/lua

local function get_basic_net_info(network, iface, accumulator)
  local net = network:get_network(iface)
  local device = net and net:get_interface()

  if device then
    accumulator["uptime"] = net:uptime()
    accumulator["iface"] = device:name()
    accumulator["mac"] = device:mac()
    accumulator["rx_bytes"] = device:rx_bytes()
    accumulator["tx_bytes"] = device:tx_bytes()
    accumulator["ipaddrs"] = {}

    for _, ipaddr in ipairs(device:ipaddrs()) do
      accumulator.ipaddrs[#accumulator.ipaddrs + 1] = {
        addr = ipaddr:host():string(),
        netmask = ipaddr:mask():string()
      }
    end
  end
end

local function get_wifi_info(network, iface, accumulator)
  local net = network:get_wifinet(iface)

  if net then
    local dev = net:get_device()
    if dev then
      accumulator["mode"] = net:active_mode()
      accumulator["ssid"] = net:active_ssid()
      accumulator["encryption"] = net:active_encryption()
      accumulator["quality"] = net:signal_percent()
    end
  end
end

local function collect_wifi_info()
  local network = require"luci.model.network".init()
  local accumulator = {}
  get_basic_net_info(network, "lan", accumulator)
  get_wifi_info(network, "wlan0", accumulator)
  return accumulator
end

local info = collect_wifi_info()

print("Current WiFi configuration")
if info.ssid then
  print("SSID: " .. info.ssid)
end
if info.mode then
  print("Mode: " .. info.mode)
end
if info.quality then
  print("Signal: " .. info.quality .. "%")
end
if info.encryption then
  print("Encryption method: " .. info.encryption)
end
if info.iface then
  print("Interface name: " .. info.iface)
end
if info.uptime then
  print("Active for: " .. math.floor(info.uptime / 60) .. " minutes")
end
if #info.ipaddrs > 0 then
  print("IP address: " .. info.ipaddrs[1].addr .. "/" .. info.ipaddrs[1].netmask)
end
if info.mac then
  print("MAC address: " .. info.mac)
end
if info.rx_bytes and info.tx_bytes then
  print("RX/TX: " .. math.floor(info.rx_bytes / 1024) .. "/" .. math.floor(info.tx_bytes / 1024) .. " KBs")
end
