local M = {}

local uci = require 'uci'

local localDomains = require 'dnsdist/local-domains'
local common = require 'dnsdist/common'
local os = require 'dnsdist/os'

local configurationCheckInterval = 0
local configurationCheckInterfacePatterns = {}
local maxPSS = 0

function M.getGeneralUCIOption(cursor, key, default)
  local value, err = cursor:get('dnsdist', 'general', key)
  if err == nil and value ~= nil then
    return value
  else
    return default
  end
end

function M.parseDNSRecordType(recordType)
  local idx = string.find(recordType, 'TYPE')
  if idx == 1 then
    recordType = string.sub(recordType, 5, -1)
    return tonumber(recordType)
  else
    if DNSQType[recordType] ~= nil then
      return DNSQType[recordType]
    end
  end
  return nil
end

local function getTLSMaterial(config)
  local cert = config['tls_cert']
  local key = config['tls_key']
  local skip = false

  if config['tls_cert_is_password_protected'] == '1' and config['tls_cert_password'] ~= nil then
    key = ''
    if os.fileExists(cert) then
      cert = newTLSCertificate(config['tls_cert'], { password = config['tls_cert_password'] })
    else
      skip = true
    end
  else
    if not os.fileExists(cert) or not os.fileExists(key) then
      skip = true
    end
  end
  return cert, key, skip
end

local function buildSentinelDomainNames()
  local sentinelDomainNames = {}

  local cursor = uci.cursor()
  cursor:foreach('dnsdist', 'domainlist', function (entry)
    local sentinelDomainName = entry['.name']
    local domainList = {}
    for _, v in pairs(entry['entry']) do
      local name, itf = string.match(v, '([^%s]+)%s([^%s]+)')
      if domainList[itf] == nil then
        domainList[itf] = {}
      end
      table.insert(domainList[itf], name)
    end
    local itfRules = {}
    for itfName, config in pairs(domainList) do
      local rules = { suffixes = nil, exact = nil }
      for _, name in pairs(config) do
        if string.sub(name, 1, 1) == '*' then
          if rules['suffixes'] == nil then
            rules['suffixes'] = newSuffixMatchNode()
          end
          rules['suffixes']:add(string.sub(name, 3, -1))
        else
          if rules['exact'] == nil then
            rules['exact'] = newDNSNameSet()
          end
          rules['exact']:add(newDNSName(name))
        end
      end
      if rules['suffixes'] == nil and rules['exact'] ~= nil then
        itfRules[itfName] = QNameSetRule(rules['exact'])
      elseif rules['suffixes'] ~= nil and rules['exact'] == nil then
        itfRules[itfName] = SuffixMatchNodeRule(rules['suffixes'])
      elseif rules['suffixes'] ~= nil and rules['exact'] ~= nil then
        itfRules[itfName] = OrRule({QNameSetRule(rules['exact']), SuffixMatchNodeRule(rules['suffixes'])})
      end
    end
    sentinelDomainNames[sentinelDomainName] = itfRules
  end)
  return sentinelDomainNames
end

local sentinelDomainsTagRules = {}
local function getRuleForSentinelDomain(sentinelDomainsListName, sentinelDomainsNameRule)
  local rule = sentinelDomainsTagRules[sentinelDomainsListName]
  if rule == nil then
    local tagName = 'stnl-' .. sentinelDomainsListName
    addAction(sentinelDomainsNameRule, SetTagAction(tagName, 'true'))
    rule = TagRule(tagName)
    sentinelDomainsTagRules[sentinelDomainsListName] = rule
  end
  return rule
end

function M.isInterfaceEnabled(includePatterns, excludePatterns, interfaceName)
  if #includePatterns > 0 then
    local enabled = false
    for _, pattern in ipairs(includePatterns) do
      if string.match(interfaceName, pattern) ~= nil then
        enabled = true
        break
      end
    end
    if not enabled then
      return false
    end
  end

  if #excludePatterns > 0 then
    for _, pattern in ipairs(excludePatterns) do
      if string.match(interfaceName, pattern) ~= nil then
        return false
      end
    end
  end

  return true
end

function M.isBridge()
  local cursor = uci.cursor()
  local value, err = cursor:get("network", "wan", "type")
  if err == nil and value == "bridge" then
    return true
  else
    return false
  end
end

function M.enabled(config)
  if config['enabled'] == '0' then
    return false
  end
  return true
end

function M.apply(config)
  if not M.enabled(config) then
    return
  end

  -- logging
  if config['verbose_mode'] == 1 then
    setVerbose(true)
    if config['verbose_log_destination'] ~= nil and #config['verbose_log_destination'] > 0 then
      vinfolog('Directing verbose-level log messages to '..config['verbose_log_destination'])
      setVerboseLogDestination(config['verbose_log_destination'])
    end
  end

  -- cache
  if config['domain_cache_size'] ~= nil and tonumber(config['domain_cache_size']) > 0 then

    setCacheCleaningDelay(tonumber(config['domain_cleanup_interval']))

    local cacheOptions = { maxTTL = tonumber(config['domain_ttl_cap']) }
    local pc = newPacketCache(tonumber(config['domain_cache_size']), cacheOptions)

    getPool(common.poolName):setCache(pc)
    if config['auto_upgraded_backends_pool'] ~= nil then
      getPool(config['auto_upgraded_backends_pool']):setCache(pc)
    end
  else
    -- make sure that the upgraded backend pool is always created, even when the cache is disabled
    if config['auto_upgraded_backends_pool'] ~= nil then
      getPool(config['auto_upgraded_backends_pool'])
    end
  end

  -- web server
  if config['api-port'] ~= nil then
    webserver("127.0.0.1:"..tonumber(config['api-port']))
    setWebserverConfig({apiRequiresAuthentication=false, acl="127.0.0.0/8"})
  end

  -- we need to retain the CAP_NET_RAW capability to be able to use a
  -- specific source interface for our backends
  local capabilitiesToRetain = {}
  local serversCount = 0
  for _, v in pairs(config['servers']) do
    serversCount = serversCount + 1
  end
  local serverIdx = 0
  for _, v in pairs(config['servers']) do
    if serverIdx >= config['max_upstream_resolvers'] then
      warnlog('Skipping upstream resolver '..v['address']..' because we already have '..config['max_upstream_resolvers']..' resolvers')
    else
      serverIdx = serverIdx + 1
      if v['source'] ~= nil then
        table.insert(capabilitiesToRetain, 'CAP_NET_RAW')
      end
      -- if we have only one upstream resolver, mark it UP as we have no other
      -- choice anyway
      if serversCount == 1 then
         infolog("Marking the only downstream server as 'UP'")
         v['healthCheckMode'] = 'up'
      end
      newServer(v)
    end
  end

  if #capabilitiesToRetain > 0 then
    addCapabilitiesToRetain(capabilitiesToRetain)
  end

  -- network interfaces
  local interfaces = getListOfNetworkInterfaces()

  local localDomainsDests = {}
  local allAddresses = {}

  local ACL = {
    '127.0.0.0/8',
    '::1/128',
  }

  local sentinelRules = buildSentinelDomainNames()
  local interfaceRules = {}
  for _, itf in ipairs(interfaces) do
    if M.isInterfaceEnabled(config['interfaces-include'], config['interfaces-exclude'], itf) then
      local conf = config['interfaces'][itf]
      if conf == nil then
        conf = config['interfaces']['default_interface']
      end

      if conf ~= nil then
        if conf['enabled'] == '1' then
          local interfaceDests = newNMG()
          local mainAddr = nil
          local additionalAddrs = {}
          local itfAddrs = {}
          local v4Addrs = {}
          local v6Addrs = {}
          local addresses = getListOfAddressesOfNetworkInterface(itf)

          for _,v in ipairs(getListOfRangesOfNetworkInterface(itf)) do
            table.insert(ACL, v)
          end

          for _, addr in ipairs(addresses) do
            if common.addrIsIPv6(addr) and string.sub(addr, 1, 1) ~= '[' then
              addr = '['..addr..']'
              if mainAddr == nil then
                mainAddr = addr
              else
                table.insert(additionalAddrs, addr)
              end
              table.insert(v6Addrs, addr)
            else
              if mainAddr == nil then
                mainAddr = addr
              else
                table.insert(additionalAddrs, addr)
              end
              table.insert(v4Addrs, addr)
            end
            table.insert(itfAddrs, addr)
            table.insert(allAddresses, addr)

            if conf['do53'] == '1' then
              local parameters = {
                maxConcurrentTCPConnections = tonumber(config['concurrent_incoming_connections_per_device'])
              }
              addLocal(addr..':'..config['do53_port'], parameters)
            end

            interfaceDests:addMask(addr)
          end

          if interfaceDests:size() > 0 then
            local itfNMGRule = NetmaskGroupRule(interfaceDests, false)
            addAction(itfNMGRule, SetTagAction(common.interfaceTagName, itf))
            interfaceRules[itf] = TagRule(common.interfaceTagName, itf)
          end

          if conf['local_resolution'] == '1' then
             table.insert(localDomainsDests, itf)
          end

          if conf['dot'] == '1' and mainAddr ~= nil then
            -- we set maxConcurrentTCPConnections here but see also
            -- setMaxTCPConnectionsPerClient() below for TCP/DoT
            local dotParameters = {
              ignoreTLSConfigurationErrors = true,
              maxConcurrentTCPConnections = tonumber(config['concurrent_incoming_connections_per_device']),
              numberOfStoredSessions = 0,
              minTLSVersion = config['tls_min_version'],
              ciphers = config['tls_ciphers_incoming'],
              ciphersTLS13 = config['tls_ciphers13_incoming']
            }
            if next(additionalAddrs) ~= nil then
              dotParameters['additionalAddresses'] = {}
              for _, v in ipairs(additionalAddrs) do
                table.insert(dotParameters['additionalAddresses'], v..':'..config['dot_port'])
	      end
            end

            local cert, key, skip = getTLSMaterial(config)
            if not skip then
              addTLSLocal(mainAddr..':'..config['dot_port'], cert, key, dotParameters)
            else
              warnlog('Not listening for DoT queries on '..mainAddr..':'..config['dot_port']..' because the certificate or key is missing')
            end
          end

          if conf['doh'] == '1' and mainAddr ~= nil then
            local dohParameters = {
              ignoreTLSConfigurationErrors = true,
              maxConcurrentTCPConnections = tonumber(config['concurrent_incoming_connections_per_device']),
              numberOfStoredSessions = 0,
              internalPipeBufferSize = 0,
              minTLSVersion = config['tls_min_version'],
              ciphers = config['tls_ciphers_incoming'],
              ciphersTLS13 = config['tls_ciphers13_incoming']
            }
            if next(additionalAddrs) ~= nil then
              dohParameters['additionalAddresses'] = {}
              for _, v in ipairs(additionalAddrs) do
                table.insert(dohParameters['additionalAddresses'], v..':'..config['doh_port'])
              end
            end

            local cert, key, skip = getTLSMaterial(config)
            if not skip then
              addDOHLocal(mainAddr..':'..config['doh_port'], cert, key, '/dns-query', dohParameters)
            else
              warnlog('Not listening for DoH queries on '..mainAddr..':'..config['doh_port']..' because the certificate or key is missing')
            end
          end

          if interfaceDests:size() > 0 and (conf['sentinel_domains'] ~= nil or conf['advertise'] == '1') then
            -- sentinel domains
            if conf['sentinel_domains'] ~= nil then
              local sentinelItfs = sentinelRules[conf['sentinel_domains']]
              for sentinelItf, sentinelDomainsRule in pairs(sentinelItfs) do
                local addresses = getListOfAddressesOfNetworkInterface(sentinelItf)
                local addressesList = {}
                for _, addr in ipairs(addresses) do
                  if common.addrIsIPv6(addr) then
                    if string.find(addr, '%%') == nil then
                      if string.sub(addr, 1, 1) ~= '[' then
                        addr = '['..addr..']'
                      end
                      table.insert(addressesList, addr)
                    end
                  else
                    table.insert(addressesList, addr)
                  end
                end
                if #addressesList > 0 then
                  local sentinelDomainsTagRule = getRuleForSentinelDomain(conf['sentinel_domains'], sentinelDomainsRule)
                  addAction(AndRule{interfaceRules[itf], sentinelDomainsTagRule}, SpoofAction(addressesList, { ttl=config['sentinel_domains_ttl'] }))
                end
              end
            end

            -- Advertise DoT /DoH via SVCB
            if conf['advertise'] == '1' then
              local namedResolver = config['advertise_for_domain_name']
              local targetName = '_dns.resolver.arpa.'
              if namedResolver ~= nil and #namedResolver > 0 then
                targetName = namedResolver
                namedResolver = '_dns.'..namedResolver
              end
              local svc = {}
              if conf['dot'] == '1' then
                table.insert(svc, newSVCRecordParameters(1, targetName, { mandatory={"port"}, alpn={ "dot" }, noDefaultAlpn=true, port=config['dot_port'], ipv4hint=v4Addrs, ipv6hint=v6Addrs }))
              end
              if conf['doh'] == '1' then
                table.insert(svc, newSVCRecordParameters(2, targetName, { mandatory={"port"}, alpn={ "h2" }, port=config['doh_port'], ipv4hint=v4Addrs, ipv6hint=v6Addrs, key7='/dns-query' }))
              end
              if #svc > 0 then
                local nameRule = nil
                if namedResolver ~= nil and #namedResolver > 0 then
                  nameRule = OrRule{QNameRule('_dns.resolver.arpa.'), QNameRule(namedResolver)}
                else
                  nameRule = QNameRule('_dns.resolver.arpa.')
                end
                addAction(AndRule{QTypeRule(DNSQType.SVCB), interfaceRules[itf], nameRule}, SpoofSVCAction(svc))
                if config['advertise_for_domain_name'] ~= nil and #config['advertise_for_domain_name'] > 0 then
                  -- basically an automatic sentinel domain rule
                  addAction(AndRule{interfaceRules[itf], QNameRule(config['advertise_for_domain_name'])}, SpoofAction(itfAddrs, { ttl=config['sentinel_domains_ttl'] }))
                end
                -- reply with NODATA (NXDOMAIN would deny all types at that name and below, including SVC) for other types
                -- but only for _dns.resolver.arpa., the advertised name might have other types
                addAction(AndRule{interfaceRules[itf], QNameRule('_dns.resolver.arpa.')}, NegativeAndSOAAction(false, '_dns.resolver.arpa.', 3600, 'fake.resolver.arpa.', 'fake.resolver.arpa.', 1, 1800, 900, 604800, 86400))
              end
            end
          end
        end
      end
    end
  end

  -- allow queries from all subnets on chosen interfaces
  setACL(ACL)

  -- tuning
  if config['concurrent_incoming_connections_per_device'] ~= nil then
    setMaxTCPConnectionsPerClient(tonumber(config['concurrent_incoming_connections_per_device']))
  end
  if config['max_idle_doh_connections_per_downstream'] ~= nil then
    setMaxIdleDoHConnectionsPerDownstream(tonumber(config['max_idle_doh_connections_per_downstream']))
  end
  if config['max_idle_tcp_connections_per_downstream'] ~= nil then
    setMaxCachedTCPConnectionsPerDownstream(tonumber(config['max_idle_tcp_connections_per_downstream']))
  end

  -- local domains interfaces
  localDomains.destinations = localDomainsDests
  for suffix in string.gmatch(config['local_domains_suffix'], '([^%s]+)') do
    table.insert(localDomains.lanSuffixes, suffix)
  end
  localDomains.ttl = tonumber(config['local_domains_ttl'])

  -- watch for configuration changes
  configurationCheckInterval = config['configuration-check-interval']

  if configurationCheckInterval > 0 then
    configurationCheckInterfacePatterns['lan-interfaces-include'] = config['interfaces-include']
    configurationCheckInterfacePatterns['lan-interfaces-exclude'] = config['interfaces-exclude']
    configurationCheckInterfacePatterns['wan-interfaces-include'] = config['wan-interfaces-include']
  end

  -- watch for maximum memory usage
  maxPSS = config['max_pss']

  -- route queries to a DoT / DoH backend, if available, and to the default pool otherwise
  if config['auto_upgraded_backends_pool'] ~= nil then
    addAction(PoolAvailableRule(config['auto_upgraded_backends_pool']), ContinueAction(PoolAction(config['auto_upgraded_backends_pool'])))
  end

  common.registerMaintenanceHook(M.maintenance)
end

function M.loadFromUCI()
  local config = {}
  local cursor = uci.cursor()

  -- Load these values even if dnsdist is not enabled,
  -- we need them to know how often to check if that changed
  config['configuration-check-interval'] = tonumber(M.getGeneralUCIOption(cursor, 'configuration_check_interval', 60))

  config['enabled'] = M.getGeneralUCIOption(cursor, 'enabled', '0')
  if config['enabled'] == '0' then
    return config
  end

  config['do53_port'] = M.getGeneralUCIOption(cursor, 'do53_port', 53)
  config['dot_port'] = M.getGeneralUCIOption(cursor, 'dot_port', 853)
  config['doh_port'] = M.getGeneralUCIOption(cursor, 'doh_port', 443)
  config['tls_cert'] = M.getGeneralUCIOption(cursor, 'tls_cert', '')
  config['tls_key'] = M.getGeneralUCIOption(cursor, 'tls_key', '')
  config['tls_cert_is_password_protected'] = M.getGeneralUCIOption(cursor, 'tls_cert_is_password_protected', '0')
  config['tls_ciphers_incoming'] = M.getGeneralUCIOption(cursor, 'tls_ciphers_incoming', '')
  config['tls_ciphers13_incoming'] = M.getGeneralUCIOption(cursor, 'tls_ciphers13_incoming', '')
  config['tls_ciphers_outgoing'] = M.getGeneralUCIOption(cursor, 'tls_ciphers_outgoing', '')
  config['tls_ciphers13_outgoing'] = M.getGeneralUCIOption(cursor, 'tls_ciphers13_outgoing', '')
  config['concurrent_incoming_connections_per_device'] = tonumber(M.getGeneralUCIOption(cursor, 'concurrent_incoming_connections_per_device', '10'))
  config['default_check_interval'] = tonumber(M.getGeneralUCIOption(cursor, 'default_check_interval', '5'))
  config['default_check_timeout'] = tonumber(M.getGeneralUCIOption(cursor, 'default_check_timeout', '1000'))
  config['default_max_check_failures'] = tonumber(M.getGeneralUCIOption(cursor, 'default_max_check_failures', '2'))
  config['default_max_upstream_concurrent_tcp_connections'] = tonumber(M.getGeneralUCIOption(cursor, 'default_max_upstream_concurrent_tcp_connections', '0'))
  config['max_idle_tcp_connections_per_downstream'] = tonumber(M.getGeneralUCIOption(cursor, 'max_idle_tcp_connections_per_downstream', '2'))
  config['max_idle_doh_connections_per_downstream'] = tonumber(M.getGeneralUCIOption(cursor, 'max_idle_doh_connections_per_downstream', '2'))
  config['outgoing_udp_sockets_per_downstream'] = tonumber(M.getGeneralUCIOption(cursor, 'outgoing_udp_sockets_per_downstream', '100'))
  config['max_upstream_resolvers'] = tonumber(M.getGeneralUCIOption(cursor, 'max_upstream_resolvers', '5'))

  -- lazy health-checks
  config['health_checks_sample_size'] = tonumber(M.getGeneralUCIOption(cursor, 'health_checks_sample_size', 100))
  config['health_checks_min_sample_count'] = tonumber(M.getGeneralUCIOption(cursor, 'health_checks_min_sample_count', 10))
  config['health_checks_threshold'] = tonumber(M.getGeneralUCIOption(cursor, 'health_checks_threshold', 20))
  config['health_checks_failed_interval']= tonumber(M.getGeneralUCIOption(cursor, 'health_checks_failed_interval', 30))
  config['health_checks_mode']= M.getGeneralUCIOption(cursor, 'health_checks_mode', 'TimeoutOrServFail')
  config['health_checks_exponential_backoff']= tonumber(M.getGeneralUCIOption(cursor, 'health_checks_exponential_backoff', 1))
  config['health_checks_max_backoff']= tonumber(M.getGeneralUCIOption(cursor, 'health_checks_max_backoff', 3600))

  -- pss
  config['max_pss'] = tonumber(M.getGeneralUCIOption(cursor, 'max_pss', 0))

  -- logging
  config['verbose_mode'] = tonumber(M.getGeneralUCIOption(cursor, 'verbose_mode', 0))
  config['verbose_log_destination'] = M.getGeneralUCIOption(cursor, 'verbose_log_destination', '')

  -- enable verbose logging very early if necessary
  -- we'll apply verbose_log_destination after startup
  if config['verbose_mode'] == 1 then
    setVerbose(true)
  end

  -- cache
  config['domain_cache_size'] = M.getGeneralUCIOption(cursor, 'domain_cache_size', '100')
  config['domain_ttl_cap'] = M.getGeneralUCIOption(cursor, 'domain_ttl_cap', '600')
  config['domain_cleanup_interval'] = M.getGeneralUCIOption(cursor, 'domain_cleanup_interval', '60')

  -- DoT / DoH advertisement
  config['advertise_for_domain_name'] = M.getGeneralUCIOption(cursor, 'advertise_for_domain_name', '')

  -- auto upgrade of discovered servers
  config['auto_upgrade_discovered_backends'] = M.getGeneralUCIOption(cursor, 'auto_upgrade_discovered_backends', '0')
  config['keep_auto_upgraded_backends'] = M.getGeneralUCIOption(cursor, 'keep_auto_upgraded_backends', '1')
  config['auto_upgraded_backends_pool'] = M.getGeneralUCIOption(cursor, 'auto_upgraded_backends_pool', 'upgraded-to-dox')

  config['local_domains_suffix'] = M.getGeneralUCIOption(cursor, 'local_domains_suffix', 'lan')
  config['local_domains_ttl'] = tonumber(M.getGeneralUCIOption(cursor, 'local_domains_ttl', '1'))
  config['sentinel_domains_ttl'] = tonumber(M.getGeneralUCIOption(cursor, 'sentinel_domains_ttl', '60'))

  -- web server
  config['api-port'] = M.getGeneralUCIOption(cursor, 'web_server_port', '9080')

  config['servers'] = {}
  cursor:foreach('dnsdist', 'server', function (entry)
    local server = {
      healthCheckMode = 'lazy',
      lazyHealthCheckSampleSize = config['health_checks_sample_size'],
      lazyHealthCheckMinSampleCount = config['health_checks_min_sample_count'],
      lazyHealthCheckThreshold = config['health_checks_threshold'],
      lazyHealthCheckFailedInterval = config['health_checks_failed_interval'],
      lazyHealthCheckMode = config['health_checks_mode'],
      lazyHealthCheckUseExponentialBackOff = (config['health_checks_exponential_backoff'] == 1),
      lazyHealthCheckMaxBackOff = config['health_checks_max_backoff'],
      lazyHealthCheckWhenUpgraded = true
    }
    local invalid = false
    server['name'] = entry['.name']
    if entry['adn'] ~= nil then
      server['subjectAltName'] = entry['adn']
    end
    local type = entry['type']
    if type == 'doh' or type == 'dot' then
      server['tls'] = 'openssl'
    end
    if entry['port'] ~= nil then
      server['address'] = entry['addr']..':'..entry['port']
    else
      server['address'] = entry['addr']..':53'
    end
    if entry['upstreamWANInterface'] ~= nil and #entry['upstreamWANInterface'] > 0 then
      local itfAddrs = getListOfAddressesOfNetworkInterface(entry['upstreamWANInterface'])
      if #itfAddrs > 0 then
        infolog('Setting WAN interface affinity for upstream resolver '..server['name']..' to '..entry['upstreamWANInterface'])
        server['source'] = entry['upstreamWANInterface']
      else
        errlog('Discarding upstream resolver '..server['name']..' because the requested interface affinity ('..entry['upstreamWANInterface']..') cannot be satisfied')
        invalid = true
      end
    end
    if entry['path'] then
      server['dohPath'] = entry['path']
    end
    if entry['validate'] == '0' then
      server['validateCertificates'] = false
    end
    if entry['maxInFlight'] ~= nil then
      server['maxInFlight'] = entry['maxInFlight']
    end
    if entry['maxConcurrentTCPConnections'] ~= nil then
      server['maxConcurrentTCPConnections'] = entry['maxConcurrentTCPConnections']
    else
      server['maxConcurrentTCPConnections'] = config['default_max_upstream_concurrent_tcp_connections']
    end
    if entry['maxCheckFailures'] ~= nil then
      server['maxCheckFailures'] = entry['maxCheckFailures']
    else
      server['maxCheckFailures'] = config['default_max_check_failures']
    end
    if entry['checkInterval'] ~= nil then
      server['checkInterval'] = entry['checkInterval']
    else
      server['checkInterval'] = config['default_check_interval']
    end
    if entry['checkTimeout'] ~= nil then
      server['checkTimeout'] = entry['checkTimeout']
    else
      server['checkTimeout'] = config['default_check_timeout']
    end
    if config['tls_ciphers_outgoing'] ~= nil and config['tls_ciphers_outgoing'] then
      server['ciphers'] = config['tls_ciphers_outgoing']
    end
    if config['tls_ciphers13_outgoing'] ~= nil and config['tls_ciphers13_outgoing'] then
      server['ciphers13'] = config['tls_ciphers13_outgoing']
    end
    if config['outgoing_udp_sockets_per_downstream'] ~= nil then
      server['sockets'] = tonumber(config['outgoing_udp_sockets_per_downstream'])
    end
    if entry['autoUpgrade'] ~= nil then
      if entry['autoUpgrade'] == true or entry['autoUpgrade'] == '1' then
        entry['autoUpgrade'] = true
      elseif entry['autoUpgrade'] == '0' then
        entry['autoUpgrade'] = false
      end
      server['autoUpgrade'] = entry['autoUpgrade']
      if entry['autoUpgradeInterval'] ~= nil then
        server['autoUpgradeInterval'] = tonumber(entry['autoUpgradeInterval'])
      end
      if entry['autoUpgradeKeep'] ~= nil then
        server['autoUpgradeKeep'] = entry['autoUpgradeKeep']
      end
      if entry['autoUpgradePool'] ~= nil then
        server['autoUpgradePool'] = entry['autoUpgradePool']
      end
      if entry['autoUpgradeDoHKey'] ~= nil then
         server['autoUpgradeDoHKey'] = tonumber(entry['autoUpgradeDoHKey'])
      end
    end

    if not invalid then
      config['servers'][server['name']] = server
    end
  end)

  if next(config['servers']) == nil then
     -- no servers found in the configuration, let's see if we learned something from DHCP
    local resolvConfFile = '/tmp/resolv.conf.d/resolv.conf.auto'
    if not os.fileExists(resolvConfFile) then
      resolvConfFile = '/tmp/resolv.conf.auto'
    end

    if os.fileExists(resolvConfFile) then
      vinfolog("Reading upstream resolvers from "..resolvConfFile..":")
      vinfolog(string.format('[[%q]]', io.open(resolvConfFile):read('a*')))
    else
      vinfolog("Not reading upstream resolvers from "..resolvConfFile.." as the file does not exist")
    end

    local resolvers = getResolvers(resolvConfFile)
    local numresolvers = 0
    for _, resolver in ipairs(resolvers) do
      local server = {
        healthCheckMode = 'lazy',
        lazyHealthCheckSampleSize = config['health_checks_sample_size'],
        lazyHealthCheckMinSampleCount = config['health_checks_min_sample_count'],
        lazyHealthCheckThreshold = config['health_checks_threshold'],
        lazyHealthCheckFailedInterval = config['health_checks_failed_interval'],
        lazyHealthCheckMode = config['health_checks_mode'],
        lazyHealthCheckUseExponentialBackOff = (config['health_checks_exponential_backoff'] == 1),
        lazyHealthCheckMaxBackOff = config['health_checks_max_backoff'],
        lazyHealthCheckWhenUpgraded = true
      }
      server['address'] = resolver
      if config['auto_upgrade_discovered_backends'] == '1' then
        server['autoUpgrade'] = true
        if config['keep_auto_upgraded_backends'] == '1' then
          server['autoUpgradeKeep'] = true
        end
        if config['auto_upgraded_backends_pool'] ~= nil then
          server['autoUpgradePool'] = config['auto_upgraded_backends_pool']
        end
        -- these settings will be inherited in case of DoT/DoH upgrade
        if config['tls_ciphers_outgoing'] ~= nil and config['tls_ciphers_outgoing'] then
          server['ciphers'] = config['tls_ciphers_outgoing']
        end
        if config['tls_ciphers13_outgoing'] ~= nil and config['tls_ciphers13_outgoing'] then
          server['ciphers13'] = config['tls_ciphers13_outgoing']
        end
      end
      if config['default_max_upstream_concurrent_tcp_connections'] ~= nil then
        server['maxConcurrentTCPConnections'] = config['default_max_upstream_concurrent_tcp_connections']
      end
      if config['default_max_check_failures'] ~= nil then
        server['maxCheckFailures'] = config['default_max_check_failures']
      end
      if config['default_check_interval'] ~= nil then
        server['checkInterval'] = config['default_check_interval']
      end
      if config['default_check_timeout'] ~= nil then
        server['checkTimeout'] = config['default_check_timeout']
      end
      if config['outgoing_udp_sockets_per_downstream'] ~= nil then
        server['sockets'] = tonumber(config['outgoing_udp_sockets_per_downstream'])
      end

      config['servers'][resolver] = server
      numresolvers = numresolvers + 1
    end

    infolog(string.format("Read %s, learned %s upstream resolvers", resolvConfFile, numresolvers))
  end

  config['interfaces'] = {}
  cursor:foreach('dnsdist', 'interface', function (itf)
    local conf = {}
    local name = itf['name']
    if name ~= nil then
      conf['enabled'] = itf['enabled']
      conf['do53'] = itf['do53']
      conf['dot'] = itf['dot']
      conf['doh'] = itf['doh']
      conf['advertise'] = itf['advertise']
      conf['policy_engine'] = itf['policy_engine']
      conf['local_resolution'] = itf['local_resolution']
      conf['sentinel_domains'] = itf['sentinel_domains']
      config['interfaces'][name] = conf
    end
  end)

  config['interfaces-include'] = {}
  config['interfaces-exclude'] = {}
  for pattern in string.gmatch(M.getGeneralUCIOption(cursor, 'network_interface_include', ''), '([^%s]+)') do
    table.insert(config['interfaces-include'], pattern)
  end
  for pattern in string.gmatch(M.getGeneralUCIOption(cursor, 'network_interface_exclude', ''), '([^%s]+)') do
    table.insert(config['interfaces-exclude'], pattern)
  end
  config['wan-interfaces-include'] = {}
  for pattern in string.gmatch(M.getGeneralUCIOption(cursor, 'network_interface_wan_include', ''), '([^%s]+)') do
    table.insert(config['wan-interfaces-include'], pattern)
  end

  collectgarbage()
  common.runConfigurationParsedHooks(config, cursor)
  collectgarbage()

  return config
end

local nextConfigurationCheck = 0
local lastConfigurationModificationTime = 0
local lastNetworkConfiguration = nil

local function isInterfaceWatched(interfaceName)
  if #configurationCheckInterfacePatterns['wan-interfaces-include'] > 0 then
    for _, pattern in ipairs(configurationCheckInterfacePatterns['wan-interfaces-include']) do
      if string.match(interfaceName, pattern) ~= nil then
        return true
      end
    end
  end

  return M.isInterfaceEnabled(configurationCheckInterfacePatterns['lan-interfaces-include'], configurationCheckInterfacePatterns['lan-interfaces-exclude'], interfaceName)
end

local function configurationChanged()
  local mtime = os.getFileModificationTime('/etc/config/dnsdist')
  if mtime ~= 0 then
    if lastConfigurationModificationTime ~= 0 and lastConfigurationModificationTime ~= mtime then
      return true
    end
    lastConfigurationModificationTime = mtime
  end

  local networkConfiguration = {}
  local interfaces = getListOfNetworkInterfaces()
  for _, itf in ipairs(interfaces) do
    if isInterfaceWatched(itf) then
      local addresses = getListOfAddressesOfNetworkInterface(itf)
      networkConfiguration[itf] = addresses
    end
  end

  if lastNetworkConfiguration ~= nil then
     for itf, addresses in pairs(lastNetworkConfiguration) do
        local newAddresses = networkConfiguration[itf]
        -- if the interface had no addresses, we do not care
        if #addresses > 0 then
          if newAddresses == nil or #newAddresses ~= #addresses then
            infolog('Addresses changed on interface '..itf)
            return true
          end
          local found = false
          -- we have the same number of addresses, so if all the existing ones
          -- are still there we should be fine
          for _, addr in ipairs(addresses) do
             for _, newAddr in ipairs(newAddresses) do
                if addr == newAddr then
                   found = true
                end
             end
            if not found then
               infolog('Addresses changed on interface '..itf)
               return true
            end
          end
        elseif newAddresses ~= nil and #newAddresses > 0 then
          infolog('Addresses changed on interface '..itf)
          return true
        end
     end
     -- now make sure that we do not have a new interface with
     -- addresses
     for itf, addresses in pairs(networkConfiguration) do
        local oldAddresses = lastNetworkConfiguration[itf]
        -- if the interface has no addresses, we do not care
        if oldAddresses == nil and #addresses > 0 then
          infolog('New interface with addresses: '..itf)
          return true
        end
     end
  end

  lastNetworkConfiguration = networkConfiguration
  return false
end

function M.maintenance()
  if configurationCheckInterval > 0 and os.time() >= nextConfigurationCheck then
    if configurationChanged() then
      warnlog("Configuration has been modified, exiting")
      os.exit(1)
    end
    if maxPSS > 0 then
      local currentPSS = os.getPSS()
      if currentPSS > maxPSS then
        warnlog("The maximum PSS value has been reached ("..currentPSS.." / "..maxPSS.."), exiting")
        os.exit(1)
      end
    end
    nextConfigurationCheck = os.time() + configurationCheckInterval
  end
end

return M
