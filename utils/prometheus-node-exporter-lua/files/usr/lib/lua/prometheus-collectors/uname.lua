local labels = {
  domainname = "",
  nodename = "",
  release = string.sub(get_contents("/proc/sys/kernel/osrelease"), 1, -2),
  sysname = string.sub(get_contents("/proc/sys/kernel/ostype"), 1, -2),
  version = string.sub(get_contents("/proc/sys/kernel/version"), 1, -2),
  machine = string.sub(io.popen("uname -m"):read("*a"), 1, -2)
}

local function scrape()
  labels["domainname"] = string.sub(get_contents("/proc/sys/kernel/domainname"), 1, -2)
  labels["nodename"] = string.sub(get_contents("/proc/sys/kernel/hostname"), 1, -2)
  metric("node_uname_info", "gauge", labels, 1)
end

return { scrape = scrape }
