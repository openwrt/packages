module("luci.controller.mwan3", package.seeall)

sys = require "luci.sys"
ut = require "luci.util"

function index()
	if not nixio.fs.access("/etc/config/mwan3") then
		return
	end

	entry({"admin", "network", "mwan3"},
		alias("admin", "network", "mwan3", "overview"),
		_("Load Balancing"), 600)

	entry({"admin", "network", "mwan3", "overview"},
		alias("admin", "network", "mwan3", "overview", "over_iface"),
		_("Overview"), 10)
	entry({"admin", "network", "mwan3", "overview", "over_iface"},
		template("mwan3/mwan3_over_interface"))
	entry({"admin", "network", "mwan3", "overview", "iface_status"},
		call("mwan3_iface_status"))
	entry({"admin", "network", "mwan3", "overview", "over_detail"},
		template("mwan3/mwan3_over_detail"))
	entry({"admin", "network", "mwan3", "overview", "detail_status"},
		call("mwan3_detail_status"))

	entry({"admin", "network", "mwan3", "configuration"},
		alias("admin", "network", "mwan3", "configuration", "interface"),
		_("Configuration"), 20)
	entry({"admin", "network", "mwan3", "configuration", "interface"},
		arcombine(cbi("mwan3/mwan3_interface"), cbi("mwan3/mwan3_interfaceconfig")),
		_("Interfaces"), 10).leaf = true
	entry({"admin", "network", "mwan3", "configuration", "member"},
		arcombine(cbi("mwan3/mwan3_member"), cbi("mwan3/mwan3_memberconfig")),
		_("Members"), 20).leaf = true
	entry({"admin", "network", "mwan3", "configuration", "policy"},
		arcombine(cbi("mwan3/mwan3_policy"), cbi("mwan3/mwan3_policyconfig")),
		_("Policies"), 30).leaf = true
	entry({"admin", "network", "mwan3", "configuration", "rule"},
		arcombine(cbi("mwan3/mwan3_rule"), cbi("mwan3/mwan3_ruleconfig")),
		_("Rules"), 40).leaf = true

	entry({"admin", "network", "mwan3", "advanced"},
		alias("admin", "network", "mwan3", "advanced", "hotplug"),
		_("Advanced"), 100)
	entry({"admin", "network", "mwan3", "advanced", "hotplug"},
		form("mwan3/mwan3_adv_hotplug"))
	entry({"admin", "network", "mwan3", "advanced", "mwan3"},
		form("mwan3/mwan3_adv_mwan3"))
	entry({"admin", "network", "mwan3", "advanced", "network"},
		form("mwan3/mwan3_adv_network"))
	entry({"admin", "network", "mwan3", "advanced", "diag"},
		template("mwan3/mwan3_adv_diagnostics"))
	entry({"admin", "network", "mwan3", "advanced", "diag_display"},
		call("mwan3_diag_data"), nil).leaf = true
	entry({"admin", "network", "mwan3", "advanced", "tshoot"},
		template("mwan3/mwan3_adv_troubleshoot"))
	entry({"admin", "network", "mwan3", "advanced", "tshoot_display"},
		call("mwan3_tshoot_data"))
end

function mwan3_get_iface_status(rulenum, ifname)
	if ut.trim(sys.exec("uci get -p /var/state mwan3." .. ifname .. ".enabled")) == "1" then
		if ut.trim(sys.exec("ip route list table " .. rulenum)) ~= "" then
			if ut.trim(sys.exec("uci get -p /var/state mwan3." .. ifname .. ".track_ip")) ~= "" then
				return "on"
			else
				return "nm"
			end
		else
			return "off"
		end
	else
		return "ne"
	end
end

function mwan3_get_iface()
	local rulenum, str = 0, ""
	uci.cursor():foreach("mwan3", "interface",
		function (section)
			rulenum = rulenum+1
			str = str .. section[".name"] .. "[" .. mwan3_get_iface_status(rulenum, section[".name"]) .. "]"
		end
	)
	return str
end

function mwan3_iface_status()
	local ntm = require "luci.model.network".init()

	local rv = {	}

	-- overview status
	local statstr = mwan3_get_iface()
	if statstr ~= "" then
		rv.wans = { }
		wansid = {}

		for wanname, ifstat in string.gfind(statstr, "([^%[]+)%[([^%]]+)%]") do
			local wanifname = ut.trim(sys.exec("uci get -p /var/state network." .. wanname .. ".ifname"))
				if wanifname == "" then
					wanifname = "X"
				end
			local wanlink = ntm:get_interface(wanifname)
				wanlink = wanlink and wanlink:get_network()
				wanlink = wanlink and wanlink:adminlink() or "#"
			wansid[wanname] = #rv.wans + 1
			rv.wans[wansid[wanname]] = { name = wanname, link = wanlink, ifname = wanifname, status = ifstat }
		end
	end

	-- overview status log
	local mwlg = ut.trim(sys.exec("logread | grep mwan3 | tail -n 50 | sed 'x;1!H;$!d;x'"))
	if mwlg ~= "" then
		rv.mwan3log = { }
		mwlog = {}
		mwlog[mwlg] = #rv.mwan3log + 1
		rv.mwan3log[mwlog[mwlg]] = { mwanlog = mwlg }
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end

function mwan3_detail_status()
	local rv = {	}

	-- detailed mwan3 status
	local dst = ut.trim(sys.exec("mwan3 status"))
	if dst ~= "" then
		rv.mwan3dst = { }
		dstat = {}
		dstat[dst] = #rv.mwan3dst + 1
		rv.mwan3dst[dstat[dst]] = { detailstat = dst }
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end

function mwan3_diag_data(iface, tool, alt)
	function get_ifnum()
		local num = 0
		uci.cursor():foreach("mwan3", "interface",
			function (section)
				num = num+1
				if section[".name"] == iface then
					ifnum = num
				end
			end
		)
	end

	local rv = {	}

	local res = ""
	if tool == "service" then
		os.execute("mwan3 " .. alt)
		if alt == "restart" then
			res = "MWAN3 restarted"
		elseif alt == "stop" then
			res = "MWAN3 stopped"
		else
			res = "MWAN3 started"
		end
	else
		local ifdev = ut.trim(sys.exec("uci get -p /var/state network." .. iface .. ".ifname"))
		if ifdev ~= "" then
			if tool == "ping" then
				local gateway = ut.trim(sys.exec("route -n | awk -F' ' '{ if ($8 == \"" .. ifdev .. "\" && $1 == \"0.0.0.0\") print $2 }'"))
				if gateway ~= "" then
					if alt == "gateway" then
						local cmd = "ping -c 3 -W 2 -I " .. ifdev .. " " .. gateway
						res = cmd .. "\n\n" .. sys.exec(cmd)
					else
						local str = ut.trim(sys.exec("uci get -p /var/state mwan3." .. iface .. ".track_ip"))
						if str ~= "" then
							for z in str:gmatch("[^ ]+") do
								local cmd = "ping -c 3 -W 2 -I " .. ifdev .. " " .. z
								res = res .. cmd .. "\n\n" .. sys.exec(cmd) .. "\n\n"
							end
						else
							res = "No tracking IP addresses configured on " .. iface
						end
					end
				else
					res = "No default gateway for " .. iface .. " found. Default route does not exist or is configured incorrectly"
				end
			elseif tool == "rulechk" then
				get_ifnum()
				local rule1 = sys.exec("ip rule | grep $(echo $((" .. ifnum .. " + 1000)))")
				local rule2 = sys.exec("ip rule | grep $(echo $((" .. ifnum .. " + 2000)))")
				if rule1 ~= "" and rule2 ~= "" then
					res = "All required interface IP rules found:\n\n" .. rule1 .. rule2
				elseif rule1 ~= "" or rule2 ~= "" then
					res = "Missing 1 of the 2 required interface IP rules\n\n\nRules found:\n\n" .. rule1 .. rule2
				else
					res = "Missing both of the required interface IP rules"
				end
			elseif tool == "routechk" then
				get_ifnum()
				local table = sys.exec("ip route list table " .. ifnum)
				if table ~= "" then
					res = "Interface routing table " .. ifnum .. " was found:\n\n" .. table
				else
					res = "Missing required interface routing table " .. ifnum
				end
			elseif tool == "hotplug" then
				if alt == "ifup" then
					os.execute("mwan3 ifup " .. iface)
					res = "Hotplug ifup sent to interface " .. iface .. "..."
				else
					os.execute("mwan3 ifdown " .. iface)
					res = "Hotplug ifdown sent to interface " .. iface .. "..."
				end
			end
		else
			res = "Unable to perform diagnostic tests on " .. iface .. ". There is no physical or virtual device associated with this interface"
		end
	end
	if res ~= "" then
		res = ut.trim(res)
		rv.diagres = { }
		dres = {}
		dres[res] = #rv.diagres + 1
		rv.diagres[dres[res]] = { diagresult = res }
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end

function mwan3_tshoot_data()
	local rv = {	}

	-- software versions
	local wrtrelease = ut.trim(luci.version.distversion)
		if wrtrelease ~= "" then
			wrtrelease = "OpenWrt - " .. wrtrelease
		else
			wrtrelease = "OpenWrt - unknown"
		end
	local lucirelease = ut.trim(luci.version.luciversion)
		if lucirelease ~= "" then
			lucirelease = "\nLuCI - " .. lucirelease
		else
			lucirelease = "\nLuCI - unknown"
		end
	local mwan3version = ut.trim(sys.exec("opkg info mwan3 | grep Version | awk -F' ' '{ print $2 }'"))
		if mwan3version ~= "" then
			mwan3version = "\n\nmwan3 - " .. mwan3version
		else
			mwan3version = "\nmwan3 - unknown"
		end
	local mwan3lversion = ut.trim(sys.exec("opkg info luci-app-mwan3 | grep Version | awk -F' ' '{ print $2 }'"))
		if mwan3lversion ~= "" then
			mwan3lversion = "\nluci-app-mwan3 - " .. mwan3lversion
		else
			mwan3lversion = "\nluci-app-mwan3 - unknown"
		end
	local softrev = wrtrelease .. lucirelease .. mwan3version .. mwan3lversion
	rv.mw3ver = { }
	mwv = {}
	mwv[softrev] = #rv.mw3ver + 1
	rv.mw3ver[mwv[softrev]] = { mwan3v = softrev }

	-- mwan3 config
	local mwcg = ut.trim(sys.exec("cat /etc/config/mwan3"))
		if mwcg == "" then
			mwcg = "No data found"
		end
	rv.mwan3config = { }
	mwan3cfg = {}
	mwan3cfg[mwcg] = #rv.mwan3config + 1
	rv.mwan3config[mwan3cfg[mwcg]] = { mwn3cfg = mwcg }

	-- network config
	local netcg = ut.trim(sys.exec("cat /etc/config/network | sed -e 's/.*username.*/	USERNAME HIDDEN/' -e 's/.*password.*/	PASSWORD HIDDEN/'"))
		if netcg == "" then
			netcg = "No data found"
		end
	rv.netconfig = { }
	ncfg = {}
	ncfg[netcg] = #rv.netconfig + 1
	rv.netconfig[ncfg[netcg]] = { netcfg = netcg }

	-- ifconfig
	local ifcg = ut.trim(sys.exec("ifconfig"))
		if ifcg == "" then
			ifcg = "No data found"
		end
	rv.ifconfig = { }
	icfg = {}
	icfg[ifcg] = #rv.ifconfig + 1
	rv.ifconfig[icfg[ifcg]] = { ifcfg = ifcg }

	-- route -n
	local routeshow = ut.trim(sys.exec("route -n"))
		if routeshow == "" then
			routeshow = "No data found"
		end
	rv.rtshow = { }
	rshw = {}
	rshw[routeshow] = #rv.rtshow + 1
	rv.rtshow[rshw[routeshow]] = { iprtshow = routeshow }

	-- ip rule show
	local ipr = ut.trim(sys.exec("ip rule show"))
		if ipr == "" then
			ipr = "No data found"
		end
	rv.iprule = { }
	ipruleid = {}
	ipruleid[ipr] = #rv.iprule + 1
	rv.iprule[ipruleid[ipr]] = { rule = ipr }

	-- ip route list table 1-250
	local routelisting, rlstr = ut.trim(sys.exec("ip rule | sed 's/://g' | awk -F' ' '$1>=2001 && $1<=2250' | awk -F' ' '{ print $NF }'")), ""
		if routelisting ~= "" then
			for line in routelisting:gmatch("[^\r\n]+") do
				rlstr = rlstr .. line .. "\n" .. sys.exec("ip route list table " .. line)
			end
			rlstr = ut.trim(rlstr)
		else
			rlstr = "No data found"
		end
	rv.routelist = { }
	rtlist = {}
	rtlist[rlstr] = #rv.routelist + 1
	rv.routelist[rtlist[rlstr]] = { iprtlist = rlstr }

	-- default firewall output policy
	local defout = ut.trim(sys.exec("uci get -p /var/state firewall.@defaults[0].output"))
		if defout == "" then
			defout = "No data found"
		end
	rv.fidef = { }
	fwdf = {}
	fwdf[defout] = #rv.fidef + 1
	rv.fidef[fwdf[defout]] = { firedef = defout }

	-- iptables
	local iptbl = ut.trim(sys.exec("iptables -L -t mangle -v -n"))
		if iptbl == "" then
			iptbl = "No data found"
		end
	rv.iptables = { }
	tables = {}
	tables[iptbl] = #rv.iptables + 1
	rv.iptables[tables[iptbl]] = { iptbls = iptbl }

	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end
