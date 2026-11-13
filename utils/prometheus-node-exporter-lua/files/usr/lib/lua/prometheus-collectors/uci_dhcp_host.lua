local uci=require("uci")

local function values(v)
  if v == nil then return {} end
  if type(v) == "table" then return v end
  return {v}
end

local function scrape()
  local curs=uci.cursor()
  local metric_uci_host = metric("uci_dhcp_host", "gauge")

  curs:foreach("dhcp", "host", function(s)
    local emitted = false
    for _, mac in ipairs(values(s["mac"])) do
      metric_uci_host({name=s["name"], dns=s["dns"], ip=s["ip"], mac=string.upper(mac)}, 1)
      emitted = true
    end
    for _, duid in ipairs(values(s["duid"])) do
      metric_uci_host({name=s["name"], dns=s["dns"], ip=s["ip"], duid=duid}, 1)
      emitted = true
    end
    if not emitted then
      metric_uci_host({name=s["name"], dns=s["dns"], ip=s["ip"]}, 1)
    end
  end)
end

return { scrape = scrape }
