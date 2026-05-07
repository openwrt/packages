local uci=require("uci")

local function scrape()
  local curs=uci.cursor()
  local metric_uci_host = metric("uci_dhcp_host", "gauge")

  curs:foreach("dhcp", "host", function(s)
    if s[".type"] == "host" then
      local macs = type(s["mac"]) == "table" and s["mac"] or {s["mac"]}
      for _, mac in ipairs(macs) do
        labels = {name=s["name"], mac=string.upper(mac), dns=s["dns"], ip=s["ip"]}
        metric_uci_host(labels, 1)
      end
    end
  end)
end

return { scrape = scrape }
