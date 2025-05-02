-- DHCP clients collector

local function get_contents(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read("*a")
    file:close()
    return content
  end
  
  local function scrape()
    local log = get_contents("/var/dhcp.leases")
    if not log then return end
  
    -- Define the metric
    local dhcp_metric = metric("dhcp_client", "gauge")

    -- DHCP entry format:
    -- 1746223910 18:56:80:88:00:5e 192.168.1.236 13172BAM 01:18:56:80:88:00:5e
    -- timestamp mac ip hostname extra_mac
    
    for line in log:gmatch("[^\r\n]+") do
      local timestamp, mac, ip, hostname, extra_mac = line:match("^(%d+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)$")
      if timestamp and mac and ip and hostname and extra_mac then
        dhcp_metric({
          mac = string.upper(mac),
          ip = ip,
          hostname = hostname ~= "*" and hostname or "unknown"
        }, 1)
      end
    end
  end
  
  return { scrape = scrape }