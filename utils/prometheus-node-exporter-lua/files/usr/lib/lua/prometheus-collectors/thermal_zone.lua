local fs = require "nixio.fs"

local function scrape()
  for zone in fs.glob("/sys/class/thermal/thermal_zone[0-9]*") do
    local temp = string.gsub(get_contents(zone .. "/temp"), "[\n|\r]", "")
    local s_type = string.gsub(get_contents(zone .. "/type"), "[\n\r]", "")
    local name = string.match(fs.basename(zone), "thermal_zone(.+)")

    metric("node_thermal_zone_temp", "gauge", {name=name, type=s_type}, temp / 1000.0)
  end
end

return { scrape = scrape }
