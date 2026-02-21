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

    if string.find(env.SERVER_ADDR, ":") == nil then
        url = "http://" .. env.SERVER_ADDR .. ":" .. env.SERVER_PORT .. "/connected.html"
    else
        url = "http://[" .. env.SERVER_ADDR .. "]:" .. env.SERVER_PORT .. "/connected.html"
    end

    body = "<!DOCTYPE html>\r\n" ..
           "<html lang=\"en\"><head>\r\n" ..
           "<title>Connected</title>\r\n" ..
           "</head><body>\r\n"..
           "<p>You are now connected. You may close this page.</p>\r\n" ..
           "</body></html>\r\n"

    uhttpd.send("Status: 302 Found\r\n")
    uhttpd.send("Server: simple-captive-portal\r\n")
    uhttpd.send("Location: " .. url .. "\r\n")
    uhttpd.send("Cache-Control: no-cache\r\n")
    uhttpd.send("Content-Type: text/html\r\n")
    uhttpd.send("Content-Length: " .. string.len(body) .. "\r\n\r\n")
    uhttpd.send(body)
end
