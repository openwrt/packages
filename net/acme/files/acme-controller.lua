module("luci.controller.acme", package.seeall)

function index()
	local page

	page = entry({"admin", "services", "acme"},
		cbi("acme"),
		_("ACME certs"), 50)
	page.dependent = false
	page.acl_depends = { "luci-app-acme" }
end
