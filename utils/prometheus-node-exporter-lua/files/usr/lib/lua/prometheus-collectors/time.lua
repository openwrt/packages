local function scrape()
  -- current time
  metric("node_time_seconds", "counter", nil, os.time())
end

return { scrape = scrape }
