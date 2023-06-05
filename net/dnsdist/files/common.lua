local M = {}

M.poolName = ''
M.interfaceTagName = 'itf'

local maintenanceHookRegistrations = {}
local configurationParsedHookRegistrations = {}
local configurationDoneHookRegistrations = {}

local string_find = string.find

function M.addrIsIPv6(addr)
  return string_find(addr, ':')
end

local function insertIntoTableIfNotExists(tab, value)
  for _, v in ipairs(tab) do
     if v == value then
       return
    end
  end
  table.insert(tab, value)
end

function M.registerMaintenanceHook(callback)
  insertIntoTableIfNotExists(maintenanceHookRegistrations, callback)
end

function M.registerConfigurationParsedHook(callback)
  insertIntoTableIfNotExists(configurationParsedHookRegistrations, callback)
end

function M.registerConfigurationDoneHook(callback)
  insertIntoTableIfNotExists(configurationDoneHookRegistrations, callback)
end

function M.runMaintenanceHooks()
  for _, callback in ipairs(maintenanceHookRegistrations) do
    callback()
  end
end

function M.runConfigurationParsedHooks(config, cursor)
  for _, callback in ipairs(configurationParsedHookRegistrations) do
    callback(config, cursor)
  end
end

function M.runConfigurationDoneHooks(config)
  for _, callback in ipairs(configurationDoneHookRegistrations) do
    callback(config)
  end
end

return M
