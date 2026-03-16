require "luci.ip"

function handle_request(env)
    local mac = nil
    luci.ip.neighbors({ dest = env.REMOTE_ADDR }, function(n) mac = n.mac end)
    if mac == nil then
        uhttpd.send("Status: 500 Internal Server Error\r\n")
        uhttpd.send("Server: simple-captive-portal\r\n")
        uhttpd.send("Content-Type: text/plain\r\n\r\n")
        uhttpd.send("ERROR: MAC not found for IP " .. env.REMOTE_ADDR)
        return
    end

    ret = os.execute("nft add element inet simple-captive-portal guest_macs { " .. tostring(mac) .. " }")
    if ret ~= 0 then
        uhttpd.send("Status: 500 Internal Server Error\r\n")
        uhttpd.send("Server: simple-captive-portal\r\n")
        uhttpd.send("Content-Type: text/plain\r\n\r\n")
        uhttpd.send("ERROR: failed to add mac to set\n")
        return
    end

    uhttpd.send("Status: 200 OK\r\n")
    uhttpd.send("Server: simple-captive-portal\r\n")
    uhttpd.send("Content-Type: text/plain\r\n\r\n")
    uhttpd.send("You now have internet access\n")
end
