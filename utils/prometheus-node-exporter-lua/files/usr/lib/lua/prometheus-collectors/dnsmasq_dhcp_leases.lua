local ubus = require "ubus"
local u = ubus.connect()

local lease_file = "/tmp/dhcp.leases"

-- get the configured lease file from uci
local lease_file_cfg = u:call("uci", "get", {config="dhcp", section="@dnsmasq[0]", option="leasefile"})
if lease_file_cfg ~= nil then
    lease_file = lease_file_cfg.value
end

local function scrape()
    local metric_dhcp = metric("dnsmasq_dhcp_lease_expiry_time_seconds", "gauge")
    f = io.input(lease_file)
    for line in f:lines() do
        i = 0
        value = 0
        labels = {}
        for token in line.gmatch(line, "[^%s]+") do
            if i == 0 then
                value = token
            elseif i == 1 then
                labels["mac"] = token:lower()
            elseif i == 2 then
                labels["ip"] = token
            elseif i == 3 then
                if token == "*" then
                    token = ""
                end
                labels["hostname"] = token
            elseif i == 4 then
                labels["uuid"] = token:lower()
            end
            i = i + 1
        end
        metric_dhcp(labels, value)
    end
    f:close()
end

return { scrape = scrape }
