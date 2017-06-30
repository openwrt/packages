module("luci.controller.shadowsocksr-libev", package.seeall)

function index()
	if not nixio.fs.access("/etc/shadowsocksr.json") then
		return
	end

	entry({"admin", "services", "shadowsocksr-libev"},
		alias("admin", "services", "shadowsocksr-libev", "general"),
		_("ShadowsocksR"), 10)

	entry({"admin", "services", "shadowsocksr-libev", "general"},
		cbi("shadowsocksr-libev/shadowsocksr-libev-general"),
		_("General Settings"), 10).leaf = true

	entry({"admin", "services", "shadowsocksr-libev", "gfwlist"},
		call("action_gfwlist"),
		_("GFW List"), 20).leaf = true

	entry({"admin", "services", "shadowsocksr-libev", "custom"},
		cbi("shadowsocksr-libev/shadowsocksr-libev-custom"),
		_("Custom List"), 30).leaf = true

	entry({"admin", "services", "shadowsocksr-libev", "watchdog"},
		call("action_watchdog"),
		_("Watchdog Log"), 40).leaf = true
end

function action_gfwlist()
	local fs = require "nixio.fs"
	local conffile = "/etc/dnsmasq.d/gfw_list.conf" 
	local gfwlist = fs.readfile(conffile) or ""
	luci.template.render("shadowsocksr-libev/gfwlistr", {gfwlist=gfwlist})
end

function action_watchdog()
	local fs = require "nixio.fs"
	local conffile = "/var/log/shadowsocksr_watchdog.log" 
	local watchdog = fs.readfile(conffile) or ""
	luci.template.render("shadowsocksr-libev/watchdogr", {watchdog=watchdog})
end
