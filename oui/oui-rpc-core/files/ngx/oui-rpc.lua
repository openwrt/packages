local cjson = require 'cjson'
local rpc = require 'oui.rpc'
local fs = require 'oui.fs'
local uci = require 'uci'

local methods = {}

local function get_request()
    if ngx.req.get_method() ~= 'POST' then
        ngx.exit(ngx.HTTP_FORBIDDEN)
    end

    ngx.req.read_body()

    local body = ngx.req.get_body_data()
    if not body then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

    local ok, req = pcall(cjson.decode, body)
    if not ok or type(req) ~= 'table' or type(req.method) ~= 'string' then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

    if type(req.param or {}) ~= 'table' then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

    return req
end

local function create_nonce()
    local nonces = ngx.shared.nonces
    local cnt = #nonces:get_keys()

    if cnt > 5 then
        ngx.log(ngx.ERR, 'The number of nonce too more')
        return nil
    end

    local nonce = rpc.random_string(32)

    -- expires in 1s
    local ok, err = nonces:set(nonce, 1, 1)
    if not ok then
        ngx.log(ngx.ERR, 'store nonce fail:', err)
        return nil
    end

    return nonce
end

methods['challenge'] = function(param)
    if type(param.username) ~= 'string' then
        ngx.log(ngx.ERR, 'username is required')
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    local c = uci.cursor()
    local found = false

    c:foreach('oui', 'user', function(s)
        if s.username == param.username then
            found = true
            return false
        end
    end)

    if not found then
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    local nonce = create_nonce()
    if not nonce then
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    ngx.say(cjson.encode({ nonce = nonce }))
end

methods['login'] = function(param)
    local username = param.username
    local password = param.password

    if type(username) ~= 'string' then
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    local c = uci.cursor()
    local valid = false
    local acl

    c:foreach('oui', 'user', function(s)
        if s.username == param.username then
            if not s.password then
                acl = s.acl
                valid = true
                return false
            end

            local nonces = ngx.shared.nonces:get_keys()
            for _, nonce in ipairs(nonces) do
                if ngx.md5(table.concat({s.password, nonce}, ':')) == password then
                    ngx.shared.nonces:delete(nonce)
                    acl = s.acl
                    valid = true
                    return false
                end
            end
            return false
        end
    end)

    if not valid then
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    local sid = rpc.create_session(username, acl)
    if not sid then
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    ngx.header['Set-Cookie'] = 'oui-sid=' .. sid
end

methods['logout'] = function(param)
    ngx.shared.sessions:delete(ngx.ctx.sid)
end

methods['authenticated'] = function(param, session)
    ngx.say(cjson.encode{ authenticated = not not session })
end

methods['call'] = function(param, session)
    local mod = param[1]
    local func = param[2]
    local args = param[3] or {}

    if type(mod) ~= 'string' or type(func) ~= 'string' or type(args) ~= 'table' then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

    local result = rpc.call(mod, func, args, session)
    if result then
        local resp = cjson.encode({ result = result}):gsub('{}','[]')
        ngx.say(resp)
    else
        ngx.say('{}')
    end
end

local req = get_request()
if not methods[req.method] then
    ngx.log(ngx.ERR, 'Oui: Not supported method: ', req.method)
    ngx.exit(ngx.HTTP_NOT_FOUND)
end

methods[req.method](req.param or {}, rpc.get_session())
