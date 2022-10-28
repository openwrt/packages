local uci = require 'uci'

local M = {}

function M.get_users()
    local c = uci.cursor()
    local users = {}

    c:foreach('oui', 'user', function(s)
        users[#users + 1] = {
            username = s.username,
            acl = s.acl,
            id = s['.name']
        }
    end)

    return { users = users }
end

function M.del_user(param)
    local c = uci.cursor()
    local id = param.id

    c:delete('oui', id)
    c:commit('oui')
end

function M.change(param)
    local c = uci.cursor()
    local password = param.password
    local acl = param.acl
    local id = param.id

    local username = c:get('oui', id, 'username')
    if username then
        c:set('oui', id, 'password', ngx.md5(username .. ':' .. password))
        c:set('oui', id, 'acl', acl or "")
        c:commit('oui')
    end
end

function M.add_user(param)
    local c = uci.cursor()
    local username = param.username
    local password = param.password
    local acl = param.acl
    local exist = false

    c:foreach('oui', 'user', function(s)
        if s.username == username then
            exist = true
            return false
        end
    end)

    if exist then
        return { code = 1, errors = 'already exist' }
    end

    local sid = c:add('oui', 'user')
    c:set('oui', sid, 'username', username)
    c:set('oui', sid, 'password', ngx.md5(username .. ':' .. password))
    c:set('oui', sid, 'acl', acl or "")
    c:commit('oui')

    return { code = 0 }
end

return M
