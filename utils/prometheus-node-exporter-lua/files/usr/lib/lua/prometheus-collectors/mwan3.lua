local ubus = require "ubus"

local function scrape()
  local u = ubus.connect()
  local s = u:call("mwan3", "status", {})

  for interface, status in pairs(s["interfaces"]) do
    local labels = {
      interface = interface,
    }
    metric("node_mwan3_interface_up", "gauge", labels, status["up"] and 1 or 0)
    metric("node_mwan3_interface_last_ping_age_seconds", "gauge", labels, status["age"])
    metric("node_mwan3_interface_online_seconds", "gauge", labels, status["online"])
    metric("node_mwan3_interface_offline_seconds", "gauge", labels, status["offline"])
    metric("node_mwan3_interface_uptime_seconds", "gauge", labels, status["uptime"])
    metric("node_mwan3_interface_score", "gauge", labels, status["score"])
    metric("node_mwan3_interface_lost", "gauge", labels, status["lost"])
    metric("node_mwan3_interface_turn", "gauge", labels, status["turn"])
    metric("node_mwan3_interface_enabled", "gauge", labels, status["enabled"] and 1 or 0)
    metric("node_mwan3_interface_running", "gauge", labels, status["running"] and 1 or 0)

    labels["status"] = status["status"]
    local status_int = -3
    if     status["status"] == "disabled" then status_int = -2
    elseif status["status"] == "notracking" then status_int = -1
    elseif status["status"] == "offline" then status_int = 0
    elseif status["status"] == "disconnecting" then status_int = 1
    elseif status["status"] == "connecting" then status_int = 2
    elseif status["status"] == "online" then status_int = 3
    end
    metric("node_mwan3_interface_status", "gauge", labels, status_int)

    for i, track_ip in pairs(status["track_ip"]) do
      local labels = {
        interface = interface,
        ip = track_ip["ip"],
      }
      metric("node_mwan3_interface_tracking_status", "gauge", labels, track_ip["status"] == "up" and 1 or 0)
      metric("node_mwan3_interface_tracking_latency_seconds", "gauge", labels, track_ip["latency"] / 1000)
      metric("node_mwan3_interface_tracking_packetloss", "gauge", labels, track_ip["packetloss"])
    end
  end
end

return { scrape = scrape }
