local cjson = require "cjson"

local function scrape()

  local file = assert(io.popen('mmcli -m any -J --signal-get', 'r'))
  file:flush()
  local output = file:read('*all')
  file:close()

  table = cjson.decode(output)

  for k,v in pairs(table["modem"]["signal"]) do
    for k2,value in pairs(v) do
      if ( tonumber(value) ~= nil ) then
        metricname = "modemmanager_signal_" .. k .. "_" .. k2
        metric(metricname, "gauge", nil, value)
      end 
    end
  end

end

return { scrape = scrape }
