local uci=require("uci")

local function scrape()
  local curs=uci.cursor()
  local metric_uci_host = metric("uci_dhcp_host", "gauge")

  curs:foreach("dhcp", "host", function(s)
    if s[".type"] == "host" then
      local macs = s["mac"]
      local name = s["name"] or ""
      local dns = s["dns"] or ""
      local ip = s["ip"] or ""

      -- Handle both single MAC (string) and multiple MACs (table/list)
      if type(macs) == "table" then
        for _, mac in ipairs(macs) do
          labels = {name=name, mac=string.upper(mac), dns=dns, ip=ip}
          metric_uci_host(labels, 1)
        end
      elseif macs then
        labels = {name=name, mac=string.upper(macs), dns=dns, ip=ip}
        metric_uci_host(labels, 1)
      end
    end
  end)
end

return { scrape = scrape }
