-- mt5311 init file, makes mt5311 importable as module 

local dir = '/usr/lib/lua/mt5311/'
local file = dir .. 'ebm.lua'
arg={}
arg[0] = file

mt5311 = assert(loadfile(file))(arg)

return mt5311

