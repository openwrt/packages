#!/usr/bin/lua

local json = require "cjson"

local function interpret_suffix(rate)
  if rate ~= nil then
    local value = string.sub(rate, 1, -2)
    local suffix = string.sub(rate, -1)
    if suffix == "K" then return tonumber(value) * 10^3 end
    if suffix == "M" then return tonumber(value) * 10^6 end
    if suffix == "G" then return tonumber(value) * 10^9 end
  end
  return rate
end

local function scrape()
  local status = json.decode(get_contents("/var/run/bmx7/json/status")).status
  local labels = {
    id = status.shortId,
    name = status.name,
    address = status.primaryIp,
    revision = status.revision,
  }

  metric("bmx7_status", "gauge", labels, 1)
  metric("bmx7_cpu_usage", "gauge", nil, status.cpu)
  metric("bmx7_mem_usage", "gauge", nil, interpret_suffix(status.mem))

  local links = json.decode(get_contents("/var/run/bmx7/json/links")).links
  local metric_bmx7_rxRate = metric("bmx7_link_rxRate","gauge")
  local metric_bmx7_txRate = metric("bmx7_link_txRate","gauge")

  for _, link in pairs(links) do
    local labels = {
      source = status.shortId,
      target = link.shortId,
      name = link.name,
      dev = link.dev
    }
    metric_bmx7_rxRate(labels, interpret_suffix(link.rxRate))
    metric_bmx7_txRate(labels, interpret_suffix(link.txRate))
    end
end

return { scrape = scrape }
