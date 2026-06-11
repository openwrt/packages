local uci=require("uci")

local function scrape()
  local curs=uci.cursor()
  local metric_uci_host = metric("uci_dhcp_host", "gauge")

  curs:foreach("dhcp", "host", function(s)
    local labels = {name=s["name"], dns=s["dns"], ip=s["ip"], duid=s["duid"]}

    if s["mac"] == nil then
      metric_uci_host(labels, 1)
      return
    end

    local macs = type(s["mac"]) == "table" and s["mac"] or {s["mac"]}
    for _, mac in ipairs(macs) do
      labels["mac"] = string.upper(mac)
      metric_uci_host(labels, 1)
    end
  end)
end

return { scrape = scrape }
