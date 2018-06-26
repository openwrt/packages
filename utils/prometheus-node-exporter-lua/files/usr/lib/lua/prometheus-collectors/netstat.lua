local netsubstat = {
    "IcmpMsg",
    "Icmp",
    "IpExt",
    "Ip",
    "TcpExt",
    "Tcp",
    "UdpLite",
    "Udp"
}

local function scrape()
  -- NOTE: Both of these are missing in OpenWRT kernels.
  --       See: https://dev.openwrt.org/ticket/15781
  local netstat = get_contents("/proc/net/netstat") .. get_contents("/proc/net/snmp")

  -- all devices
  for i, nss in ipairs(netsubstat) do
    local substat_s = string.match(netstat, nss .. ": ([A-Z][A-Za-z0-9 ]+)")
    if substat_s then
      local substat = space_split(substat_s)
      local substatv = space_split(string.match(netstat, nss .. ": ([0-9 -]+)"))
      for ii, ss in ipairs(substat) do
        metric("node_netstat_" .. nss .. "_" .. ss, "gauge", nil, substatv[ii])
      end
    end
  end
end

return { scrape = scrape }
