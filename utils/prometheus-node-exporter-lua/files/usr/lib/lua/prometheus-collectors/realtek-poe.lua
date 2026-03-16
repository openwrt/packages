require "ubus"

local METRIC_NAMESPACE = "realtek_poe"

-- possible poe modes for a port
--   realtek-poe/src/main.c
--   static int poe_reply_port_ext_config()
local POE_MODES = {
    "PoE",
    "Legacy",
    "pre-PoE+",
    "PoE+"
}

-- possible poe states for a port
--   realtek-poe/src/main.c
--   static int poe_reply_4_port_status()
local POE_STATES = {
    "Disabled",
    "Searching",
    "Delivering power",
    "Fault",
    "Other fault",
    "Requesting power"
}

-- --
-- scraping function
-- --
local function scrape()
    -- connect to ubus
    local conn = ubus.connect()
    if not conn then
        error("Failed to connect to ubusd")
    end

    -- call poe info
    local poe_info = conn:call("poe", "info", {})
    if not poe_info then
        error("Failed to call 'poe info'. Is realtek-poe installed and running ?")
    end

    -- close ubus handle
    conn:close()

    -- helper vars
    local mcu         = poe_info["mcu"]
    local ports       = poe_info["ports"]
    local budget      = poe_info["budget"]
    local firmware    = poe_info["firmware"]
    local consumption = poe_info["consumption"]

    -- push info, budget and consumption metric
    metric(METRIC_NAMESPACE .. "_switch_info", "gauge", { mcu=mcu, firmware=firmware }, 1)
    metric(METRIC_NAMESPACE .. "_switch_budget_watts", "gauge", nil, budget)
    metric(METRIC_NAMESPACE .. "_switch_consumption_watts", "gauge", nil, consumption)

    -- push per port priority metrics
    local priority_metric = metric(METRIC_NAMESPACE .. "_port_priority", "gauge")
    for port, values in pairs(ports) do
        priority_metric({ device=port }, values["priority"])
    end

    -- push per port consumption metrics
    local consumption_metric = metric(METRIC_NAMESPACE .. "_port_consumption_watts", "gauge")
    for port, values in pairs(ports) do
        consumption_metric({ device=port }, (values["consumption"] ~= nil and values["consumption"] or 0))
    end

    -- push per port state metrics
    local state_metric = metric(METRIC_NAMESPACE .. "_port_state", "gauge")
    for _, state in ipairs(POE_STATES) do
        for port, values in pairs(ports) do
            state_metric({ device=port, state=state }, (values["status"] == state and 1 or 0))
        end
    end

    -- push per port mode metrics
    local mode_metric = metric(METRIC_NAMESPACE .. "_port_mode", "gauge")
    for _, mode in ipairs(POE_MODES) do
        for port, values in pairs(ports) do
            mode_metric({ device=port, mode=mode }, (values["mode"] == mode and 1 or 0))
        end
    end
end

return { scrape = scrape }
