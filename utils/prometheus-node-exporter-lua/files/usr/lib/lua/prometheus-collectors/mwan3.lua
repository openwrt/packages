local ubus = require "ubus"

local function scrape()
    local u = ubus.connect()
    local status = u:call("mwan3", "status", {})
    if status == nil then
        error("Could not get mwan3 status")
    end

    local node_mwan3_age = metric("node_mwan3_interfaces_age", "counter")
    local node_mwan3_online = metric("node_mwan3_interfaces_online", "counter")
    local node_mwan3_offline = metric("node_mwan3_interfaces_offline", "counter")
    local node_mwan3_uptime = metric("node_mwan3_interfaces_uptime", "counter")
    local node_mwan3_score = metric("node_mwan3_interfaces_score", "gauge")
    local node_mwan3_lost = metric("node_mwan3_interfaces_lost", "counter")
    local node_mwan3_turn = metric("node_mwan3_interfaces_turn", "counter")
    local node_mwan3_status = metric("node_mwan3_interfaces_status", "gauge")
    local node_mwan3_enabled = metric("node_mwan3_interfaces_enabled", "gauge")
    local node_mwan3_running = metric("node_mwan3_interfaces_running", "gauge")
    local node_mwan3_up = metric("node_mwan3_interfaces_up", "gauge")

    local possible_status = {"offline", "online", "disconnecting", "connecting", "disabled", "notracking", "unknown"}

    for iface, iface_details in pairs(status.interfaces) do
        node_mwan3_age({interface = iface}, iface_details.age)
        node_mwan3_online({interface = iface}, iface_details.online)
        node_mwan3_offline({interface = iface}, iface_details.offline)
        node_mwan3_uptime({interface = iface}, iface_details.uptime)
        node_mwan3_score({interface = iface}, iface_details.score)
        node_mwan3_lost({interface = iface}, iface_details.lost)
        node_mwan3_turn({interface = iface}, iface_details.turn)
        for _, s in ipairs(possible_status) do
            local is_active_status = iface_details.status == s and 1 or 0
            node_mwan3_status({interface = iface, status = s}, is_active_status)
        end
        node_mwan3_enabled({interface = iface}, iface_details.enabled and 1 or 0)
        node_mwan3_running({interface = iface}, iface_details.running and 1 or 0)
        node_mwan3_up({interface = iface}, iface_details.up and 1 or 0)
    end

end

return { scrape = scrape }
