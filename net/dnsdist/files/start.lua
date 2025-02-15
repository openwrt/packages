local useUCI = true

includeDirectory('/etc/dnsdist.conf.d/')

collectgarbage()
local common = require 'dnsdist/common'
local localDomains = require 'dnsdist/local-domains'
local dnsdistOs = require 'dnsdist/os'
common.registerConfigurationDoneHook(localDomains.run)
collectgarbage()
collectgarbage()
collectgarbage("setpause", 100)

-- fixed configuration options
setMaxUDPOutstanding(50)
setMaxTCPClientThreads(1)
setOutgoingDoHWorkerThreads(1)
setRingBuffersSize(300, 1)
setRingBuffersOptions({recordResponses=false})
setMaxTCPQueuedConnections(10)
setOutgoingTLSSessionsCacheMaxTicketsPerBackend(5)
setTCPInternalPipeBufferSize(0)
setMaxTCPQueuedConnections(100)
setRandomizedIdsOverUDP(true)
setRandomizedOutgoingSockets(true)

if useUCI then
   local status, _ = pcall(require, 'uci')
   if status then
     local configuration = require 'dnsdist/configuration'
     local config = configuration.loadFromUCI()
     collectgarbage()
     local loggedonce = false

     while not configuration.enabled(config) or configuration.isBridge() do
        local waitTime = tonumber(config['configuration-check-interval'])
        if not configuration.enabled(config) then
          if not loggedonce then
            errlog('Not starting up yet - we are disabled in the configuration')
          end
          vinfolog('Currently disabled by configuration, next check in '..waitTime..' seconds')
        else
          if not loggedonce then
            errlog('Not starting up yet - the router is in bridge mode')
          end
          vinfolog('The router is currently in bridge mode, next check in '..waitTime..' seconds')
        end

        loggedonce = true

        local ret = dnsdistOs.sleep(tonumber(waitTime))
        if ret > 0 then
          -- sleep was interrupted
          errlog('Sleep was interrupted - exiting')
          os.exit(1)
        end
        config = configuration.loadFromUCI()
        collectgarbage()
        collectgarbage()
     end

     configuration.apply(config)

     common.runConfigurationDoneHooks(config)

     function maintenance()
       common.runMaintenanceHooks()
     end

     config = nil
     collectgarbage()
     collectgarbage()
     return
   else
     errlog('Loading of the configuration from UCI requested but UCI support is not available')
     return
   end
end
