local rpc = require 'oui.rpc'
local ubus = require 'ubus'

local M = {}

function M.call(param, session)
    local object = param.object
    local method = param.method

    if not rpc.acl_match(session, param.object .. '.' .. param.method, 'ubus') then
        ngx.exit(ngx.HTTP_FORBIDDEN)
    end

    local conn = ubus.connect()
    local res = conn:call(object, method, param.param or {})
    conn:close()

    return res
end

return M
