local function scrape()
  local meminfo = line_split(get_contents("/proc/meminfo"):gsub("[):]", ""):gsub("[(]", "_"))

  for i, mi in ipairs(meminfo) do
    local name, size, unit = unpack(space_split(mi))
    if unit == 'kB' then
      size = size * 1024
    end
    metric("node_memory_" .. name, "gauge", nil, size)
  end
end

return { scrape = scrape }
