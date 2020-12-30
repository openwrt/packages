require "nixio.fs"

local function scrape()
  for line in io.lines("/proc/self/mounts")
  do
    local fs = space_split(line)
    local labels = {
      fstype = fs[3],
      mountpoint = fs[2]
    }
    local stat = nixio.fs.statvfs(fs[2])
    metric("node_filesystem_avail_bytes", "gauge", labels, stat["bavail"]*stat["frsize"])
    metric("node_filesystem_size_bytes", "gauge", labels, stat["blocks"]*stat["frsize"])
  end
end

return { scrape = scrape }
