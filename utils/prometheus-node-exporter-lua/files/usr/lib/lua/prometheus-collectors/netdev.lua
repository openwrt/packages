local function scrape()
  local netdevstat = line_split(get_contents("/proc/net/dev"))
  local netdevsubstat = {"receive_bytes", "receive_packets", "receive_errs",
                   "receive_drop", "receive_fifo", "receive_frame", "receive_compressed",
                   "receive_multicast", "transmit_bytes", "transmit_packets",
                   "transmit_errs", "transmit_drop", "transmit_fifo", "transmit_colls",
                   "transmit_carrier", "transmit_compressed"}
  for i, line in ipairs(netdevstat) do
    netdevstat[i] = string.match(netdevstat[i], "%S.*")
  end
  local nds_table = {}
  local devs = {}
  for i, nds in ipairs(netdevstat) do
    local dev, stat_s = string.match(netdevstat[i], "([^:]+): (.*)")
    if dev then
      nds_table[dev] = space_split(stat_s)
      table.insert(devs, dev)
    end
  end
  for i, ndss in ipairs(netdevsubstat) do
    netdev_metric = metric("node_network_" .. ndss, "gauge")
    for ii, d in ipairs(devs) do
      netdev_metric({device=d}, nds_table[d][i])
    end
  end
end

return { scrape = scrape }
