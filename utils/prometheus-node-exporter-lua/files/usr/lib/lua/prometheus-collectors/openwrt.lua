local ubus = require "ubus"
local u = ubus.connect()
local b = u:call("system", "board", {})

local labels = {
    board_name = b.board_name,
    id = b.release.distribution,
    model = b.model,
    release = b.release.version,
    revision = b.release.revision,
    system = b.system,
    target = b.release.target
}

local os_info = {
    id = string.lower(b.release.distribution),
    name = b.release.distribution,
    pretty_name = b.release.distribution .. " " .. b.release.version,
    version = b.release.version,
    version_id = b.release.version,
    build_id = b.release.revision,
}

local b = nil
local u = nil
local ubus = nil

local function scrape()
    metric("node_openwrt_info", "gauge", labels, 1)
    metric("node_os_info", "gauge", os_info, 1)
end

return { scrape = scrape }
