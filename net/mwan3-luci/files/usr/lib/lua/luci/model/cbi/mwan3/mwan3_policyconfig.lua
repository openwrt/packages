-- ------ extra functions ------ --

function policy_check() -- check to see if this policy's name exceed the maximum of 15 characters
	polchar = string.len(arg[1])
	if polchar > 15 then
		toolong = 1
	end
end

function policy_warn() -- display status and warning messages at the top of the page
	if toolong == 1 then
		return "<font color=\"ff0000\"><strong>WARNING: this policy's name is " .. polchar .. " characters exceeding the maximum of 15!</strong></font>"
	else
		return ""
	end
end

function cbi_add_member(field)
	uci.cursor():foreach("mwan3", "member",
		function (section)
			field:value(section[".name"])
		end
	)
end

-- ------ policy configuration ------ --

dsp = require "luci.dispatcher"
arg[1] = arg[1] or ""

toolong = 0
policy_check()


m5 = Map("mwan3", translate("MWAN3 Multi-WAN Policy Configuration - " .. arg[1]),
	translate(policy_warn()))
	m5.redirect = dsp.build_url("admin", "network", "mwan3", "configuration", "policy")


mwan_policy = m5:section(NamedSection, arg[1], "policy", "")
	mwan_policy.addremove = false
	mwan_policy.dynamic = false


use_member = mwan_policy:option(DynamicList, "use_member", translate("Member used"))
	cbi_add_member(use_member)


-- ------ currently configured members ------ --

mwan_member = m5:section(TypedSection, "member", translate("Currently Configured Members"))
	mwan_member.addremove = false
	mwan_member.dynamic = false
	mwan_member.sortable = false
	mwan_member.template = "cbi/tblsection"


return m5
