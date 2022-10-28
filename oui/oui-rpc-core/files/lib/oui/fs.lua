local M = {}

local C = require 'oui.internal.fs'

for k, v in pairs(C) do
    M[k] = v
end

function M.writefile(path, data, mode)
    local f, err = io.open(path, mode or 'w')
    if not f then
        return nil, err
    end

    f:write(data)
    f:close()

    return true
end

function M.readfile(path, format)
    local f, err = io.open(path, 'r')
    if not f then
        return nil, err
    end

    local data, err = f:read(format or '*a')
    f:close()

    return data, err
end

return M
