-- ------ network configuration ------ --

ut = require "luci.util"

netfile = "/etc/config/network"


m5 = SimpleForm("networkconf", nil)
	m5:append(Template("mwan3/mwan3_adv_network")) -- highlight current tab


f = m5:section(SimpleSection, nil,
	translate("This section allows you to modify the contents of /etc/config/network"))

t = f:option(TextValue, "lines")
	t.rmempty = true
	t.rows = 20

	function t.cfgvalue()
		return nixio.fs.readfile(netfile) or ""
	end

	function t.write(self, section, data) -- format and write new data to script
		return nixio.fs.writefile(netfile, "\n" .. ut.trim(data:gsub("\r\n", "\n")) .. "\n")
	end

	function f.handle(self, state, data)
		return true
	end


return m5
