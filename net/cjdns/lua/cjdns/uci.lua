common = require("cjdns/common")
uci    = require("uci")

UCI = {}
common.uci = UCI

--- Return the configuration defaults as a table suitable for JSON output
--
-- Mostly taken from cjdroute --genconf
-- @return table with configuration defaults
function UCI.defaults()
  return {
    security = {
      { setuser = "nobody", keepNetAdmin = 1 },
      { chroot = "/var/run/" },
      { nofiles = 0 },
      { noforks = 1 },
      { seccomp = 0 },
      { setupComplete = 1 }
    },
    router = {
        supernodes = {},
        ipTunnel = { outgoingConnections = {}, allowedConnections = {} },
        interface = { type = "TUNInterface" }
    },
    interfaces = { UDPInterface = {}, ETHInterface = {} },
    authorizedPasswords = {},
    logging = { logTo = "stdout" }
  }
end

--- Return the cjdns configuration as a table suitable for JSON output
--
-- Iterates over cjdns, eth_interface, udp_interface, eth_peer, udp_peer,
-- and password sections. Doesn't include IPTunnel related options yet.
-- @return table with cjdns configuration
function UCI.get()
  local obj = UCI.defaults()

  local cursor = uci.cursor()

  local config = cursor:get_all("cjdns", "cjdns")
  if not config then return obj end

  obj.ipv6 = config.ipv6
  obj.publicKey = config.public_key
  obj.privateKey = config.private_key
  obj.admin = {
    bind = config.admin_address .. ":" .. config.admin_port,
    password = config.admin_password }

  if config.tun_device and string.len(config.tun_device) > 0 then
    obj.router.interface.tunDevice = config.tun_device
  end

  for i,section in pairs(obj.security) do
    if type(section.seccomp) == "number" then
      obj.security[i].seccomp = tonumber(config.seccomp)
    end
  end

  cursor:foreach("cjdns", "iptunnel_outgoing", function(outgoing)
    table.insert(obj.router.ipTunnel.outgoingConnections, outgoing.public_key)
  end)

  cursor:foreach("cjdns", "iptunnel_allowed", function(allowed)
    entry = { publicKey = allowed.public_key }
    if allowed.ipv4 then
      entry["ip4Address"] = allowed.ipv4
    end
    if allowed.ipv6 then
      entry["ip6Address"] = allowed.ipv6
    end
    table.insert(obj.router.ipTunnel.allowedConnections, entry)
  end)

  cursor:foreach("cjdns", "eth_interface", function(eth_interface)
    table.insert(obj.interfaces.ETHInterface, {
      bind = eth_interface.bind,
      beacon = tonumber(eth_interface.beacon),
      connectTo = {}
    })
  end)

  cursor:foreach("cjdns", "udp_interface", function(udp_interface)
    table.insert(obj.interfaces.UDPInterface, {
      bind = udp_interface.address .. ":" .. udp_interface.port,
      connectTo = {}
    })
  end)

  cursor:foreach("cjdns", "eth_peer", function(eth_peer)
    if not eth_peer.address == "" then
      local i = tonumber(eth_peer.interface)
      obj.interfaces.ETHInterface[i].connectTo[eth_peer.address] = {
        publicKey = eth_peer.public_key,
        password = eth_peer.password
      }
    end
  end)

  cursor:foreach("cjdns", "udp_peer", function(udp_peer)
    local bind = udp_peer.address .. ":" .. udp_peer.port
    local i = tonumber(udp_peer.interface)
    obj.interfaces.UDPInterface[i].connectTo[bind] = {
      user = udp_peer.user,
      publicKey = udp_peer.public_key,
      password = udp_peer.password
    }
  end)

  cursor:foreach("cjdns", "password", function(password)
    table.insert(obj.authorizedPasswords, {
      password = password.password,
      user = password.user,
      contact = password.contact
    })
  end)

  return obj
end

--- Parse and save updated configuration from JSON input
--
-- Transforms general settings, ETHInterface, UDPInterface, connectTo, and
-- authorizedPasswords fields into UCI sections, and replaces the UCI config's
-- contents with them.
-- @param table JSON input
-- @return Boolean whether saving succeeded
function UCI.set(obj)
  local cursor = uci.cursor()

  for i, section in pairs(cursor:get_all("cjdns")) do
    cursor:delete("cjdns", section[".name"])
  end

  local admin_address, admin_port = string.match(obj.admin.bind, "^(.*):(.*)$")
  UCI.cursor_section(cursor, "cjdns", "cjdns", "cjdns", {
    ipv6 = obj.ipv6,
    public_key = obj.publicKey,
    private_key = obj.privateKey,
    admin_password = obj.admin.password,
    admin_address = admin_address,
    admin_port = admin_port
  })

  if obj.router.interface.tunDevice then
    UCI.cursor_section(cursor, "cjdns", "cjdns", "cjdns", {
      tun_device = tostring(obj.router.interface.tunDevice)
    })
  end

  if obj.security then
    for i,section in pairs(obj.security) do
      for key,value in pairs(section) do
        if key == "seccomp" then
          UCI.cursor_section(cursor, "cjdns", "cjdns", "cjdns", {
            seccomp = tonumber(value)
          })
        end
      end
    end
  end

  if obj.router.ipTunnel.outgoingConnections then
    for i,public_key in pairs(obj.router.ipTunnel.outgoingConnections) do
      UCI.cursor_section(cursor, "cjdns", "iptunnel_outgoing", nil, {
        public_key = public_key
      })
    end
  end

  if obj.router.ipTunnel.allowedConnections then
    for i,allowed in pairs(obj.router.ipTunnel.allowedConnections) do
      entry = { public_key = allowed.publicKey }
      if allowed.ip4Address then
        entry["ipv4"] = allowed.ip4Address
      end
      if allowed.ip6Address then
        entry["ipv6"] = allowed.ip6Address
      end

      UCI.cursor_section(cursor, "cjdns", "iptunnel_allowed", nil, entry)
    end
  end

  if obj.interfaces.ETHInterface then
    for i,interface in pairs(obj.interfaces.ETHInterface) do
      UCI.cursor_section(cursor, "cjdns", "eth_interface", nil, {
        bind = interface.bind,
        beacon = tostring(interface.beacon)
      })

      if interface.connectTo then
        for peer_address,peer in pairs(interface.connectTo) do
          UCI.cursor_section(cursor, "cjdns", "eth_peer", nil, {
            interface = i,
            address = peer_address,
            public_key = peer.publicKey,
            password = peer.password
          })
        end
      end
    end
  end

  if obj.interfaces.UDPInterface then
    for i,interface in pairs(obj.interfaces.UDPInterface) do
      local address, port = string.match(interface.bind, "^(.*):(.*)$")
      UCI.cursor_section(cursor, "cjdns", "udp_interface", nil, {
        address = address,
        port = port
      })

      if interface.connectTo then
        for peer_bind,peer in pairs(interface.connectTo) do
          local peer_address, peer_port = string.match(peer_bind, "^(.*):(.*)$")
          UCI.cursor_section(cursor, "cjdns", "udp_peer", nil, {
            interface = i,
            address = peer_address,
            port = peer_port,
            user = peer.user,
            public_key = peer.publicKey,
            password = peer.password
          })
        end
      end
    end
  end

  if obj.authorizedPasswords then
    for i,password in pairs(obj.authorizedPasswords) do
      local user = password.user
      if not user or string.len(user) == 0 then
        user = "user-" .. UCI.random_string(6)
      end

      UCI.cursor_section(cursor, "cjdns", "password", nil, {
        password = password.password,
        user = user,
        contact = password.contact
      })
    end
  end

  return cursor:save("cjdns")
end

--- Simple backport of Cursor:section from luci.model.uci
--
-- Backport reason: we don't wanna depend on LuCI.
-- @param Cursor the UCI cursor to operate on
-- @param string name of the config
-- @param string type of the section
-- @param string name of the section (optional)
-- @param table config values
function UCI.cursor_section(cursor, config, type, section, values)
  if section then
    cursor:set(config, section, type)
  else
    section = cursor:add("cjdns", type)
  end

  for k,v in pairs(values) do
    cursor:set(config, section, k, v)
  end
end

function UCI.makeInterface()
  local cursor = uci.cursor()

  local config = cursor:get_all("cjdns", "cjdns")
  if not config then return nil end

  return common.AdminInterface.new({
    host = config.admin_address,
    port = config.admin_port,
    password = config.admin_password,
    config = UCI.get(),
    timeout = 2
  })
end

function UCI.random_string(length)
  -- tr -cd 'A-Za-z0-9' < /dev/urandom
  local urandom = io.popen("tr -cd 'A-Za-z0-9' 2> /dev/null < /dev/urandom", "r")
  local string = urandom:read(length)
  urandom:close()
  return string
end
