-- thermal collector
local function scrape()
  local i = 0
  local temp_metric = metric("node_thermal_zone_temp", "gauge")

  while true do
    local zonePath = "/sys/class/thermal/thermal_zone" .. i

    -- required attributes

    local typ = string.match(get_contents(zonePath .. "/type"), "^%s*(.-)%s*$")
    if not typ then
      break
    end

    local policy = string.match(get_contents(zonePath .. "/policy"), "^%s*(.-)%s*$")
    if not policy then
      break
    end

    local temp = string.match(get_contents(zonePath .. "/temp"), "(%d+)")
    if not temp then
      break
    end

    local labels = {zone = i, type = typ, policy = policy}

    -- optional attributes

    local mode = string.match(get_contents(zonePath .. "/mode"), "^%s*(.-)%s*$")
    if mode then
      labels.mode = mode
    end

    local passive = string.match(get_contents(zonePath .. "/passive"), "(%d+)")
    if passive then
      labels.passive = passive
    end

    temp_metric(labels, temp / 1000)

    i = i + 1
  end
end

return { scrape = scrape }
