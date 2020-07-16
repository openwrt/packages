
local fs = require "nixio.fs"

local function scrape()
  for dir in fs.glob("/sys/class/thermal/thermal_zone*/") do
    local typ = get_contents(dir .. "type")
    -- local policy = get_contents(dir .. "policy")
    local temp = get_contents(dir .. "temp")
    if type and temp then
       local labels = {}
       labels.type = string.sub(typ, 0, -2)
       labels.zone = string.gsub(dir, ".*/thermal_zone(%d+)/", "%1")
       temp = tonumber(temp) / 1000
       output("# HELP node_thermal_zone_temp Zone temperature in Celsius")
       metric("node_thermal_zone_temp", "gauge", labels, temp)
    end
  end
end

return { scrape = scrape }
