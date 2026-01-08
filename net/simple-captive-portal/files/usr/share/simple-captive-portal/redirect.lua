port_portal = os.getenv("PORT_PORTAL")

function handle_request(env)
    if string.find(env.SERVER_ADDR, ":") == nil then
        url = "http://" .. env.SERVER_ADDR .. ":" .. port_portal .. "/"
    else
        url = "http://[" .. env.SERVER_ADDR .. "]:" .. port_portal .. "/"
    end

    body = "<!DOCTYPE html>\r\n" ..
           "<html lang=\"en\"><head>\r\n" ..
           "<title>Redirecting to login</title>\r\n" ..
           "</head><body>\r\n"..
           "<p>Redirecting to login page...</p>\r\n" ..
           "<p><a href=\"" .. url .. "\">" ..
           "Click here if the page does not automatically redirect." ..
           "</a></p>\r\n" ..
           "</body></html>\r\n"

    uhttpd.send("Status: 302 Found\r\n")
    uhttpd.send("Server: simple-captive-portal\r\n")
    uhttpd.send("Location: " .. url .. "\r\n")
    uhttpd.send("Cache-Control: no-cache\r\n")
    uhttpd.send("Content-Type: text/html\r\n")
    uhttpd.send("Content-Length: " .. string.len(body) .. "\r\n\r\n")
    uhttpd.send(body)
end
