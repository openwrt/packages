local cjson = require "cjson"

local function scrape()
  local file, output, data

  file = io.popen("mmcli -L -J", 'r')
  if not file then return end
  output = file:read('*all')
  file:close()

  local ok, modem_list = pcall(cjson.decode, output)
  if not ok or not modem_list["modem-list"] then return end

  for _, modem in ipairs(modem_list["modem-list"]) do

    file = io.popen("mmcli -m " .. modem .. " -J", 'r')
    if file then
      output = file:read('*all')
      file:close()

      ok, data = pcall(cjson.decode, output)
      if ok and data["modem"] then
        local quality = data["modem"]["generic"]["signal-quality"]["value"]
        metric("modemmanager_signal_quality", "gauge", {modem=modem}, tonumber(quality))
      end
    end

    file = io.popen("mmcli -m " .. modem .. " --signal-get -J", 'r')
    if file then
      output = file:read('*all')
      file:close()

      ok, data = pcall(cjson.decode, output)
      if ok and data["modem"] and data["modem"]["signal"] then
        for tech, values in pairs(data["modem"]["signal"]) do
          for metric_name, value in pairs(values) do
            local num = tonumber(value)
            if num then
              metric("modemmanager_signal_" .. tech .. "_" .. metric_name, "gauge", {modem=modem}, num)
            end
          end
        end
      end
    end
  end
end

return { scrape = scrape }
