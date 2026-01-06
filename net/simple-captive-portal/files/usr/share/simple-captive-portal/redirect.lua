port_portal = os.getenv("PORT_PORTAL")

function handle_request(env)
    uhttpd.send("Status: 302 Found\r\n")
    uhttpd.send("Server: simple-captive-portal\r\n")
    if string.find(env.SERVER_ADDR, ":") == nil then
        uhttpd.send("Location: http://" .. env.SERVER_ADDR .. ":" .. port_portal .. "/\r\n")
    else
        uhttpd.send("Location: http://[" .. env.SERVER_ADDR .. "]:" .. port_portal .. "/\r\n")
    end
    uhttpd.send("Cache-Control: no-cache\r\n")
    uhttpd.send("Content-Length: 0\r\n\r\n")
end
