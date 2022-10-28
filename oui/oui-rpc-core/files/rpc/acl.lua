local cjson = require 'cjson'
local rpc = require 'oui.rpc'
local fs = require 'oui.fs'

local M = {}

function M.load()
    return rpc.load_acl()
end

function M.set(param)
    for group, acls in pairs((param.acls)) do
        fs.writefile('/usr/share/oui/acl/' .. group .. '.json', cjson.encode(acls))
    end

    rpc.load_acl()
end

return M
