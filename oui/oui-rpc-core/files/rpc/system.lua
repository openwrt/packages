local fs = require 'oui.fs'
local uci = require 'uci'

local M = {}

function M.get_cpu_time()
    local result = {}

    for line in io.lines('/proc/stat') do
        local cpu = line:match('^(cpu%d?)')
        if cpu then
            local times = {}
            for field in line:gmatch('%S+') do
                if not field:match('cpu') then
                    times[#times + 1] = tonumber(field)
                end
            end
            result[cpu] = times
        end
    end

    return { times = result }
end

function M.sysupgrade(param)
    ngx.timer.at(0.5, function()
        local arg = param.keep and '' or '-n'
        os.execute('sysupgrade ' .. arg .. ' /tmp/firmware.bin')
    end)
end

function M.create_backup(param)
    local path = param.path
    os.execute('sysupgrade -b ' .. path)
end

function M.list_backup(param)
    local path = param.path

    local f = io.popen('tar -tzf ' .. path)
    if not f then
        return
    end

    local files = f:read('*a')

    f:close()

    return { files = files }
end

function M.restore_backup(param)
    os.execute('sysupgrade -r ' .. param.path)

    ngx.timer.at(0.5, function()
        os.execute('reboot')
    end)
end

function M.reset()
    ngx.timer.at(0.5, function()
        os.execute('firstboot -y && reboot')
    end)
end

return M
