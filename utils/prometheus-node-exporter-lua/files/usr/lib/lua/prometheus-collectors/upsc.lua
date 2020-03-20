-- 
-- to work you need to have installed nut-upsc package and configured with name nutdev1
-- or change here in command with your own name from nutdev1 -> your custom ups name
--

local function split(s, delimiter)
    result = {}; 
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end 
    return result;
end
local function scrape()
    local f = assert(io.popen('/usr/bin/upsc nutdev1'))
    local lbld = nil
    for e in f:lines() do
        local b=split(e,':')
	local metric_type = ""
	-- print("upsc_" .. b[1]:gsub('%.','_') .. " " .. b[2])
	local metname = 'upsc_' .. b[1]:match"^%s*(.*)":match"(.-)%s*$":gsub('%.','_')
        local metvalue = b[2]:match"^%s*(.*)":match"(.-)%s*$"
	if metname:find('upsc_battery.') ~= nil then
		metric(metname, "gauge", nil, metvalue)
		_G[metname] = metvalue
	elseif metname:find('upsc_input.') ~= nil then
		metric(metname,"gauge",nil,metvalue)
		_G[metname] = metvalue
	elseif metname:find('upsc_ups.status') ~= nil then
		if metvalue:find('OL') ~= nil then
			metvalue=1
		else
			metvalue=0
		end
		metric(metname,"gauge",nul,metvalue)
		_G[metname] = metvalue
        elseif metname:find('upsc_driver.') ~= nil then
		ress = b[1]:gsub('driver.',''):gsub('%.','_')
  		if lbld == nil then
                   lbld = ress .. '="' .. metvalue:gsub('%+','') .. '"'
		else
		   lbld = lbld .. ',' .. ress .. '="' .. metvalue:gsub('%+','') .. '"'
		end
	end
    end 
end
return { scrape = scrape }

