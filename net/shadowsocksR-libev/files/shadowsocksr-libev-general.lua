local fs = require "nixio.fs"
local conffile = "/etc/shadowsocksr.json" 

f = SimpleForm("general", translate("ShadowsocksR  - General Settings"), translate("This is the config file for ShadowsocksR."))

t = f:field(TextValue, "conf")
t.rmempty = true
t.rows = 20
function t.cfgvalue()
	return fs.readfile(conffile) or ""
end

function f.handle(self, state, data)
	if state == FORM_VALID then
		if data.conf then
			fs.writefile(conffile, data.conf:gsub("\r\n", "\n"))
			luci.sys.call("/etc/init.d/shadowsocksr restart")
		end
	end
	return true
end

return f
