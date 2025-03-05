#!/usr/bin/lua

local fs = require "nixio.fs"

local function scrape()
  local mtime_metric = metric("node_textfile_mtime_seconds", "gauge")

  for metrics in fs.glob("/var/prometheus/*.prom") do
    output(get_contents(metrics), '\n')
    local stat = fs.stat(metrics)
    if stat then
      mtime_metric({ file = metrics }, stat.mtime)
    end
  end
end

return { scrape = scrape }
