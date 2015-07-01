module("luci.controller.shadowsocks", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/shadowsocks") then
		return
	end

	entry({"admin", "services", "shadowsocks"}, cbi("shadowsocks"), _("ShadowSocks"), 74).dependent = true
end
