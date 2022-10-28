local M = {}

local C = require 'oui.internal.network'

for k, v in pairs(C) do
    M[k] = v
end

return M
