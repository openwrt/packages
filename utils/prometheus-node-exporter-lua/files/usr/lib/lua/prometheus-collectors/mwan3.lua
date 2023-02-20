local ubus = require "ubus"

local function scrape()
    local u = ubus.connect()
    local status = u:call("mwan3", "status", {})
    if status == nil then
        error("Could not get mwan3 status")
    end

    local mwan3_age = metric("mwan3_interface_age", "counter")
    local mwan3_online = metric("mwan3_interface_online", "counter")
    local mwan3_offline = metric("mwan3_interface_offline", "counter")
    local mwan3_uptime = metric("mwan3_interface_uptime", "counter")
    local mwan3_score = metric("mwan3_interface_score", "gauge")
    local mwan3_lost = metric("mwan3_interface_lost", "counter")
    local mwan3_turn = metric("mwan3_interface_turn", "counter")
    local mwan3_status = metric("mwan3_interface_status", "gauge")
    local mwan3_enabled = metric("mwan3_interface_enabled", "gauge")
    local mwan3_running = metric("mwan3_interface_running", "gauge")
    local mwan3_up = metric("mwan3_interface_up", "gauge")

    local possible_status = {"offline", "online", "disconnecting", "connecting", "disabled", "notracking", "unknown"}

    for iface, iface_details in pairs(status.interfaces) do
        mwan3_age({interface = iface}, iface_details.age)
        mwan3_online({interface = iface}, iface_details.online)
        mwan3_offline({interface = iface}, iface_details.offline)
        mwan3_uptime({interface = iface}, iface_details.uptime)
        mwan3_score({interface = iface}, iface_details.score)
        mwan3_lost({interface = iface}, iface_details.lost)
        mwan3_turn({interface = iface}, iface_details.turn)
        for _, s in ipairs(possible_status) do
            local is_active_status = iface_details.status == s and 1 or 0
            mwan3_status({interface = iface, status = s}, is_active_status)
        end
        mwan3_enabled({interface = iface}, iface_details.enabled and 1 or 0)
        mwan3_running({interface = iface}, iface_details.running and 1 or 0)
        mwan3_up({interface = iface}, iface_details.up and 1 or 0)
    end

end

return { scrape = scrape }
