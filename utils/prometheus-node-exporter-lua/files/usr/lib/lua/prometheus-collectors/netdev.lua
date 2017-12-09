
local netdevsubstat = {"receive_bytes", "receive_packets", "receive_errs",
                   "receive_drop", "receive_fifo", "receive_frame", "receive_compressed",
                   "receive_multicast", "transmit_bytes", "transmit_packets",
                   "transmit_errs", "transmit_drop", "transmit_fifo", "transmit_colls",
                   "transmit_carrier", "transmit_compressed"}
local pattern = "([^%s:]+):%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)"

local function scrape()
  local nds_table = {}
  for line in io.lines("/proc/net/dev") do
    local t = {string.match(line, pattern)}
    if #t == 17 then
      nds_table[t[1]] = t
    end
  end
  for i, ndss in ipairs(netdevsubstat) do
    netdev_metric = metric("node_network_" .. ndss, "gauge")
    for dev, nds_dev in pairs(nds_table) do
      netdev_metric({device=dev}, nds_dev[i+1])
    end
  end
end

return { scrape = scrape }
