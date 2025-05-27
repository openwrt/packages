local cjson = require "cjson"

local function scrape()
  
  local output, file, table, metricname

  file = assert(io.popen("mmcli -L -J", 'r'))
  file:flush()
  output = file:read('*all')
  file:close()
  table = cjson.decode(output)

  for i, modem in ipairs(table["modem-list"]) do

    file = assert(io.popen("mmcli -m " .. modem .. " -J", 'r'))
    file:flush()
    output = file:read('*all')
    file:close()
    table = cjson.decode(output)
  
    local value = table["modem"]["generic"]["signal-quality"]["value"]
    metricname = "modemmanager_signal_quality"
    metric(metricname, "gauge", {modem=modem}, value)

    local file = assert(io.popen("mmcli -m " .. modem .. " -J --signal-get", 'r'))
    file:flush()
    local output = file:read('*all')
    file:close()
    table = cjson.decode(output)

    for k,v in pairs(table["modem"]["signal"]) do
      for k2,value in pairs(v) do
        if ( tonumber(value) ~= nil ) then
          metricname = "modemmanager_signal_" .. k .. "_" .. k2
          metric(metricname, "gauge", {modem=modem}, value)
        end 
      end
    end

  end
end

return { scrape = scrape }
