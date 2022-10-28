local cjson = require 'cjson'
local rpc = require 'oui.rpc'
local fs = require 'oui.fs'
local uci = require 'uci'

local M = {}

function M.get_locale()
    local c = uci.cursor()
    local locale = c:get('oui', 'global', 'locale')

    return { locale = locale }
end

function M.get_theme()
    local c = uci.cursor()
    local theme = c:get('oui', 'global', 'theme')

    return { theme = theme }
end

function M.get_menus(param, session)
    local menus = {}

    for file in fs.dir('/usr/share/oui/menu.d') do
        if file:match('^%w.*%.json$') then
            local data = fs.readfile('/usr/share/oui/menu.d/' .. file)
            local menu = cjson.decode(data)
            for name, info in pairs(menu) do
                if rpc.acl_match(session, name, 'menu') then
                    menus[name] = info
                end
            end
        end
    end

    return { menus = menus }
end

return M
