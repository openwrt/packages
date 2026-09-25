local function scrape()
  local available_bits = get_contents("/proc/sys/kernel/random/entropy_avail")
  local pool_size_bits = get_contents("/proc/sys/kernel/random/poolsize")

  metric("node_entropy_available_bits", "gauge", nil, available_bits)
  metric("node_entropy_pool_size_bits", "gauge", nil, pool_size_bits)
end

return { scrape = scrape }
