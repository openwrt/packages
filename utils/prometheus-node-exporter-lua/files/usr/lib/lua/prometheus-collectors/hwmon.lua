#!/usr/bin/lua

local fs = require "nixio.fs"

local function rtrim(s)
  return string.gsub(s, "\n$", "")
end

local function scrape()
  local metric_chip_names = metric("node_hwmon_chip_names", "gauge")
  local metric_sensor_label = metric("node_hwmon_sensor_label", "gauge")
  local metric_temp_celsius = metric("node_hwmon_temp_celsius", "gauge")
  local metric_pwm = metric("node_hwmon_pwm", "gauge")

  for hwmon_path in fs.glob("/sys/class/hwmon/hwmon*") do
    -- Produce node_hwmon_chip_names
    -- See https://github.com/prometheus/node_exporter/blob/7c564bcbeffade3dacac43b07c2eeca4957ca71d/collector/hwmon_linux.go#L415
    local chip_name = rtrim(get_contents(hwmon_path .. "/name"))
    if chip_name == "" then
      chip_name = fs.basename(hwmon_path)
    end

    -- See https://github.com/prometheus/node_exporter/blob/7c564bcbeffade3dacac43b07c2eeca4957ca71d/collector/hwmon_linux.go#L355
    local chip = chip_name
    local real_dev_path, status = fs.realpath(hwmon_path .. "/device")
    if not status then
      local dev_name = fs.basename(real_dev_path)
      local dev_type = fs.basename(fs.dirname(real_dev_path))
      chip = dev_type .. "_" .. dev_name
    end
    metric_chip_names({chip=chip, chip_name=chip_name}, 1)

    -- Produce node_hwmon_sensor_label
    for sensor_path in fs.glob(hwmon_path .. "/*_label") do
      local sensor = string.gsub(fs.basename(sensor_path), "_label$", "")
      local sensor_label = rtrim(get_contents(sensor_path))
      metric_sensor_label({chip=chip, sensor=sensor, label=sensor_label}, 1)
    end

    -- Produce node_hwmon_temp_celsius
    for sensor_path in fs.glob(hwmon_path .. "/temp*_input") do
      local sensor = string.gsub(fs.basename(sensor_path), "_input$", "")
      local temp = get_contents(sensor_path) / 1000
      metric_temp_celsius({chip=chip, sensor=sensor}, temp)
    end

    -- Produce node_hwmon_pwm
    for sensor_path in fs.glob(hwmon_path .. "/pwm*") do
      local sensor = fs.basename(sensor_path)
      if string.match(sensor, "^pwm[0-9]+$") then
        local pwm = rtrim(get_contents(sensor_path))
        metric_pwm({chip=chip, sensor=sensor}, pwm)
      end
    end
  end
end

return { scrape = scrape }
