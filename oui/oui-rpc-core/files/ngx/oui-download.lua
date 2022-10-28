local cjson = require 'cjson'

if ngx.req.get_method() ~= 'POST' then
    ngx.exit(ngx.HTTP_FORBIDDEN)
end

ngx.req.read_body()

local body = ngx.req.get_body_data()
if not body then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local ok, req = pcall(cjson.decode, body)
if not ok or type(req) ~= 'table' then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local path = req.path

if not path then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local f, err = io.open(path)
if not f then
    error(err)
end

while true do
    local data = f:read(4096)
    if not data then
        break
    end
    ngx.print(data)
end

f:close()
