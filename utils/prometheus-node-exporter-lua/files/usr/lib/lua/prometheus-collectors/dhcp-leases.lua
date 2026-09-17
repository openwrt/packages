local ubus = require("ubus")

local function get_vendor(conn, mac)
  local ok, result = pcall(conn.call, conn, "fingerprint", "fingerprint", {macaddr = mac})
  if ok and result and result.vendor then
    return result.vendor
  end
  return ""
end

local function scrape()
  local dhcp_client = metric("dhcp_client", "gauge")
  local conn = ubus.connect()
  local f = io.open("/tmp/dhcp.leases", "r")
  if f then
    for line in f:lines() do
      local mac, ip, hostname = line:match("%S+ (%S+) (%S+) (%S+)")
      if mac then
        if hostname == "*" then hostname = "" end
        local vendor = conn and get_vendor(conn, mac) or ""
        dhcp_client({mac=mac:upper(), ip=ip, hostname=hostname, vendor=vendor}, 1)
      end
    end
    f:close()
  end
  if conn then conn:close() end
end

return { scrape = scrape }
