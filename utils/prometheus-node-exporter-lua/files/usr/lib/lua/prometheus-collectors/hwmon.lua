local fs = require "nixio.fs"

local function scrape()
  local temp_metric = metric("node_hwmon_temp_celsius", "gauge")
  for dir in fs.glob("/sys/class/thermal/thermal_zone0/hwmon*") do
    for file in fs.glob(string.format("%s/temp*_input", dir)) do
      local chip = get_contents(string.format("%s/name", dir)):gsub("%s+", "")
      local sensor = string.match(file,"(temp%d)")
      local temp = get_contents(file) / 1000.0
      temp_metric({chip=chip, sensor=sensor}, temp)
    end
  end
end

return { scrape = scrape }
