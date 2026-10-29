local uci=require("uci")

local function values(v)
  if v == nil then return {false} end
  if type(v) == "table" then return v end
  return {v}
end

local function scrape()
  local curs=uci.cursor()
  local metric_uci_host = metric("uci_dhcp_host", "gauge")

  curs:foreach("dhcp", "host", function(s)
    for _, mac in ipairs(values(s["mac"])) do
      for _, duid in ipairs(values(s["duid"])) do
        metric_uci_host({name=s["name"], dns=s["dns"], ip=s["ip"],
                         mac=mac and string.upper(mac) or nil, duid=duid or nil}, 1)
      end
    end
  end)
end

return { scrape = scrape }
