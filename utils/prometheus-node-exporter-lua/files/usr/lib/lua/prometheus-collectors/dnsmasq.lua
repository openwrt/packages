local ubus = require "ubus"

local function scrape_leasefile(leasefile)
  metric_dhcp_lease = metric("dhcp_lease", "gauge")
  local file = io.open(leasefile)
  if not file then return end

  local e
  repeat
    e = file:read()
    if e then
      local fields = space_split(e)
      if fields[4] ~= nil then
        local labels = {
          dnsmasq = leasefile,
          ip = fields[3],
          hostname = fields[4]
        }
        if string.match(fields[3], "^[0-9]+%.[0-9]+%.[0-9]+%.[0-9]+$") then
          labels['mac'] = fields[2]
        end
        metric_dhcp_lease(labels, fields[1])
      end
    end
  until not e
  file:close()
end

local function scrape()
  local u = ubus.connect()

  local metrics = u:call("dnsmasq", "metrics", {})
  if not metrics then return end
  for name, value in pairs(metrics) do
    metric("dnsmasq_"..name, "counter", nil, value)
  end

  local values = u:call("uci", "get", {config="dhcp", type="dnsmasq"})
  if not values then return end
  for _, configs in pairs(values) do
    for name, config in pairs(configs) do
      for key, value in pairs(config) do
        if key == "leasefile" then
	  scrape_leasefile(value)
        end
      end
    end
  end
end

return { scrape = scrape }
