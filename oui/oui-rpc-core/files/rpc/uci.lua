local rpc = require 'oui.rpc'
local uci = require 'uci'

local M = {}

function M.load(param, section)
    local config = param.config
    local c = uci.cursor()

    if not rpc.acl_match(session, config, 'uci') then
        ngx.exit(ngx.HTTP_FORBIDDEN)
    end

    return c:get_all(param.config)
end

function M.get(param, session)
    local c = uci.cursor()
    local config = param.config
    local section = param.section
    local option = param.option

    if not rpc.acl_match(session, config, 'uci') then
        ngx.exit(ngx.HTTP_FORBIDDEN)
    end

    return c:get(config, section, option)
end

function M.set(param, session)
    local c = uci.cursor()
    local config = param.config
    local section = param.section

    if not rpc.acl_match(session, config, 'uci') then
        ngx.exit(ngx.HTTP_FORBIDDEN)
    end

    for option, value in pairs(param.values) do
        c:set(config, section, option, value)
    end

    c:commit(config)
end

function M.delete(param, session)
    local c = uci.cursor()
    local config = param.config
    local section = param.section
    local options = param.options

    if not rpc.acl_match(session, config, 'uci') then
        ngx.exit(ngx.HTTP_FORBIDDEN)
    end

    if options then
        for _, option in ipairs(options) do
            c:delete(config, section, option)
        end
    else
        c:delete(config, section)
    end

    c:commit(config)
end

function M.add(param, session)
    local c = uci.cursor()
    local config = param.config
    local typ = param.type
    local name = param.name
    local values = param.values

    if not rpc.acl_match(session, config, 'uci') then
        ngx.exit(ngx.HTTP_FORBIDDEN)
    end

    if name then
        c:set(config, name, typ)
    else
        name = c:add(config, typ)
    end

    for option, value in pairs(values) do
        c:set(config, name, option, value)
    end

    c:commit(config)
end

return M
