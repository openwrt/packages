--[[
Copyright (C) 2014-2017 - Eloi Carbo

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]--

local fs = require "nixio.fs"
local functions_dir = "/etc/bird4/functions/"
local lock_file = "/etc/bird4/function_lock"

m = SimpleForm("bird4", "Bird4 Functions", "<b>INFO:</b> New files are created using Timestamps.<br />In order to make it easier to handle, use SSH to connect to your terminal and rename those files.<br />If your file is not correctly shown in the list, please, refresh your browser.")

s = m:section(SimpleSection)
files = s:option(ListValue, "Files", "Function Files:")
local new_function = functions_dir .. os.date("function-%Y%m%d-%H%M")

-- New File Entry
files:value(new_function, "New File (".. new_function .. ")")
files.default = new_function

local i, file_list = 0, { }
for filename in io.popen("find " .. functions_dir .. " -type f"):lines() do
    i = i + 1
    files:value(filename, filename)
end

ld = s:option(Button, "_load", "Load File")
ld.inputstyle = "reload"

st_file = s:option(DummyValue, "_stfile", "Editing file:")
function st_file.cfgvalue(self, section)
    if ld:formvalue(section) then
        fs.writefile(lock_file, files:formvalue(section))
        return files:formvalue(section)
    else
        fs.writefile(lock_file, "")
        return ""
    end
end

area = s:option(Value, "_functions")
area.template = "bird4/tvalue"
area.rows = 30
function area.cfgvalue(self,section)
    if ld:formvalue(section) then
        local contents = fs.readfile(files:formvalue(section))
        if contents then
            return contents
        else
            return ""
        end
    else
        return ""
    end
end

function area.write(self, section)
    local locked_file = fs.readfile(lock_file)
    if locked_file and not ld:formvalue(section) then
        local text = self:formvalue(section):gsub("\r\n?", "\n")
        fs.writefile(locked_file, text)
        fs.writefile(lock_file, "")
    end
end

return m
