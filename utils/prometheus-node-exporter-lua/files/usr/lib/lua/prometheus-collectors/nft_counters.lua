local json = require "cjson"

local function scrape()
  local handle = io.popen("nft --json list counters")
  local result = handle:read("*a")
  handle:close()
  local nft_data = json.decode(result).nftables

  local metric_packets = metric("nft_counter_packets", "counter")
  local metric_bytes = metric("nft_counter_bytes", "counter")

  for _, data in pairs(nft_data) do
    if (data.counter ~= nil) then
      local labels = {
        family = data.counter.family,
        table = data.counter.table,
        name = data.counter.name,
        comment = data.counter.comment
      }
      metric_packets(labels, data.counter.packets)
      metric_bytes(labels, data.counter.bytes)
    end
  end
end

return { scrape = scrape }
