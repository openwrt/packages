local cjson = require 'cjson'
local fs = require 'oui.fs'
local uci = require 'uci'

local M = {
    SESSION_TIMEOUT = 30 * 60
}

local no_auth_funcs
local funcs = {}
local acls

local function load_no_auth()
    local c = uci.cursor()

    no_auth_funcs = {}

    c:foreach('oui', 'no-auth', function(s)
        no_auth_funcs[s.module] = {}

        for _, func in ipairs(s.func or {}) do
            no_auth_funcs[s.module][func] = true
        end
    end)
end

local function need_auth(mod, func)
    local is_local = ngx.var.remote_addr == '127.0.0.1' or ngx.var.remote_addr == '::1'

    if is_local then
        return false
    end

    if not no_auth_funs then
        load_no_auth()
    end

    return not no_auth_funcs[mod] or not no_auth_funcs[mod][func]
end

function M.load_acl()
    acls = {}

    for file in fs.dir('/usr/share/oui/acl') do
        local data = fs.readfile('/usr/share/oui/acl/' .. file)
        acls[file:match('(.*).json')] = cjson.decode(data)
    end

    return acls
end

function M.random_string(n)
    local t = {
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
        'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
        'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    }
    local s = {}
    for i = 1, n do
        s[#s + 1] = t[math.random(#t)]
    end

    return table.concat(s)
end

function M.create_session(username, acl)
    local sessions = ngx.shared.sessions
    local sid = M.random_string(32)
    local session = {
        username = username,
        acl = acl
    }

    local ok, err = sessions:set(sid, cjson.encode(session), M.SESSION_TIMEOUT)
    if not ok then
        ngx.log(ngx.ERR, 'store session fail:', err)
        return nil
    end

    return sid
end

function M.get_session()
    local cookie = {}
    if ngx.var.http_cookie then
        ngx.var.http_cookie:gsub('[^ ;]+', function(t)
            local b = t:find('=')
            if b ~= nil then
                cookie[t:sub(1, b - 1)] = t:sub(b + 1)
            end
        end)
    end

    local sid = cookie['oui-sid']
    if not sid then
        return nil
    end

    local sessions = ngx.shared.sessions
    local session = sessions:get(sid)

    if not session then
        return
    end

    ngx.ctx.sid = sid

    sessions:set(sid, session, M.SESSION_TIMEOUT)

    return cjson.decode(session)
end

function M.acl_match(session, content, class)
    if not session then return true end

    if not session.acls then
        return false
    end

    if not session.acls[class] then return false end

    local matchs = session.acls[class].matchs
    if not matchs then
        return false
    end

    for _, pattern in ipairs(matchs) do
        if content:match(pattern) then
            return not session.acls[class].reverse
        end
    end

    return session.acls[class].reverse
end

function M.call(mod, func, args, session)
    if not funcs[mod] then
        local script = '/usr/share/oui/rpc/' .. mod .. '.lua'

        local ok, tb = pcall(dofile, script)
        if not ok then
            ngx.log(ngx.ERR, tb)
            ngx.exit(ngx.HTTP_NOT_FOUND)
        end

        if type(tb) == 'table' then
            funcs[mod] = tb
        end
    end

    if not funcs[mod] or not funcs[mod][func] then
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end

    if not session and need_auth(mod, func) then
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    if not acls then
        M.load_acl()
    end

    if session then
        session.acls = acls[session.acl]

        if not M.acl_match(session, mod .. '.' .. func, 'rpc') then
            ngx.exit(ngx.HTTP_FORBIDDEN)
        end
    end

    return funcs[mod][func](args, session)
end

return M
