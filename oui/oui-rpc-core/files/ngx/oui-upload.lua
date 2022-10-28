local upload = require 'resty.upload'
local rpc = require 'oui.rpc'
local cjson = require 'cjson'
local md5 = require 'oui.md5'
local fs = require 'oui.fs'

local function need_auth()
    local is_local = ngx.var.remote_addr == '127.0.0.1' or ngx.var.remote_addr == '::1'

    if not rpc.get_session() and not is_local then
        return true
    end

    return false
end

local function get_content_length()
    local header = ngx.var.content_length
    if not header then
        return nil
    end

    return tonumber(header)
end

if need_auth() then
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

local content_length = get_content_length()
if not content_length then
    error('no Content-length')
end

local form, err = upload:new()
if not form then
    error(err)
end

form:set_timeout(10000)

local md5ctx = md5.new()
local contents = {}
local size = 0
local name
local file

while true do
    local typ, res, err = form:read()
    if not typ then
        error(err)
    end

    if typ == 'header' and #res > 1 and res[1]:lower() == "content-disposition" then
        name = res[2]:match('name="(%w+)"')
        if not name then
           error('invalid header: ' .. table.concat(res, ';'))
        end
        contents[name] = {}
    elseif typ == "body" then
        if name == 'file' then
            if not contents['path'] then
                ngx.log(ngx.ERR, 'Not found path')
                ngx.exit(403)
            end

            if not file then
                path = contents['path']
                file, err = io.open(path, 'w+')
                if not file then
                    error('open ' .. path .. ' fail: ' .. err)
                end
            end

            size = size + #res
            md5ctx:hash(res)
            file:write(res)
        else
            local content = contents[name]
            content[#content + 1] = res
        end
    elseif typ == 'part_end' then
        contents[name] = table.concat(contents[name])

        if name == 'path' then
            local dir = fs.dirname(contents[name])
            local _, a = fs.statvfs(dir)
            if a < content_length / 1024 then
                ngx.log(ngx.ERR, 'No enough space left on device')
                ngx.exit(413)
            end
        elseif name == 'file' then
            if file then
                file:close()
            end
        end
    end

    if typ == "eof" then break end
end

if not file then
    error('not found file')
end

ngx.say(cjson.encode({
    size = size,
    md5 = md5ctx:done()
}))
