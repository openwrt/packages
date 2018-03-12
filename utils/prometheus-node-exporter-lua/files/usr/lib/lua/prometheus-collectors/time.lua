local function scrape()
  -- current time
  metric("node_time", "counter", nil, os.time())
end

return { scrape = scrape }
