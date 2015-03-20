--[[
LuCI - Lua Configuration Interface

Copyright 2014 Steven Barth <steven@midlink.org>
Copyright 2014 Dave Taht <dave.taht@bufferbloat.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

local wa = require "luci.tools.webadmin"
local fs = require "nixio.fs"
local net = require "luci.model.network".init()
local sys = require "luci.sys"
--local ifaces = net:get_interfaces()
local ifaces = sys.net:devices()
local path = "/usr/lib/sqm"

m = Map("sqm", translate("Smart Queue Management"),
	translate("With <abbr title=\"Smart Queue Management\">SQM</abbr> you " ..
		"can enable traffic shaping, better mixing (Fair Queueing)," ..
		" active queue length management (AQM) " ..
		" and prioritisation on one " ..
		"network interface."))

s = m:section(TypedSection, "queue", translate("Queues"))
s:tab("tab_basic", translate("Basic Settings"))
s:tab("tab_qdisc", translate("Queue Discipline"))
s:tab("tab_linklayer", translate("Link Layer Adaptation"))
s.addremove = true -- set to true to allow adding SQM instances in the GUI
s.anonymous = true

-- BASIC
e = s:taboption("tab_basic", Flag, "enabled", translate("Enable"))
e.rmempty = false

n = s:taboption("tab_basic", ListValue, "interface", translate("Interface name"))
-- sm lifted from luci-app-wol, the original implementation failed to show pppoe-ge00 type interface names
for _, iface in ipairs(ifaces) do
--     if iface:is_up() then
--	n:value(iface:name())
--     end
	if iface ~= "lo" then 
		n:value(iface) 
	end
end
n.rmempty = false


dl = s:taboption("tab_basic", Value, "download", translate("Download speed (kbit/s) (ingress):"))
dl.datatype = "and(uinteger,min(0))"
dl.rmempty = false

ul = s:taboption("tab_basic", Value, "upload", translate("Upload speed (kbit/s) (egress):"))
ul.datatype = "and(uinteger,min(0))"
ul.rmempty = false

-- QDISC

c = s:taboption("tab_qdisc", ListValue, "qdisc", translate("Queueing discipline"))
c:value("fq_codel", "fq_codel ("..translate("default")..")")
c:value("efq_codel")
c:value("nfq_codel")
c:value("sfq")
c:value("codel")
c:value("ns2_codel")
c:value("pie")
c:value("sfq")
c.default = "fq_codel"
c.rmempty = false

local qos_desc = ""
sc = s:taboption("tab_qdisc", ListValue, "script", translate("Queue setup script"))
for file in fs.dir(path) do
  if string.find(file, ".qos$") then
    sc:value(file)
  end
  if string.find(file, ".qos.help$") then
    fh = io.open(path .. "/" .. file, "r")
    qos_desc = qos_desc .. "<p><b>" .. file:gsub(".help$", "") .. ":</b><br />" .. fh:read("*a") .. "</p>"
  end
end
sc.default = "simple.qos"
sc.rmempty = false
sc.description = qos_desc

ad = s:taboption("tab_qdisc", Flag, "qdisc_advanced", translate("Show and Use Advanced Configuration"))
ad.default = false
ad.rmempty = true

squash_dscp  = s:taboption("tab_qdisc", ListValue, "squash_dscp", translate("Squash DSCP on inbound packets (ingress):"))
squash_dscp:value("1", "SQUASH")
squash_dscp:value("0", "DO NOT SQUASH")
squash_dscp.default = "1"
squash_dscp.rmempty = true
squash_dscp:depends("qdisc_advanced", "1")

squash_ingress = s:taboption("tab_qdisc", ListValue, "squash_ingress", translate("Ignore DSCP on ingress:"))
squash_ingress:value("1", "Ignore")
squash_ingress:value("0", "Allow")
squash_ingress.default = "1"
squash_ingress.rmempty = true
squash_ingress:depends("qdisc_advanced", "1")

iecn = s:taboption("tab_qdisc", ListValue, "ingress_ecn", translate("Explicit congestion notification (ECN) status on inbound packets (ingress):"))
iecn:value("ECN", "ECN ("..translate("default")..")")
iecn:value("NOECN")
iecn.default = "ECN"
iecn.rmempty = true
iecn:depends("qdisc_advanced", "1")

eecn = s:taboption("tab_qdisc", ListValue, "egress_ecn", translate("Explicit congestion notification (ECN) status on outbound packets (egress)."))
eecn:value("NOECN", "NOECN ("..translate("default")..")")
eecn:value("ECN")
eecn.default = "NOECN"
eecn.rmempty = true
eecn:depends("qdisc_advanced", "1")

ad2 = s:taboption("tab_qdisc", Flag, "qdisc_really_really_advanced", translate("Show and Use Dangerous Configuration"))
ad2.default = false
ad2.rmempty = true
ad2:depends("qdisc_advanced", "1")

ilim = s:taboption("tab_qdisc", Value, "ilimit", translate("Hard limit on ingress queues; leave empty for default."))
-- ilim.default = 1000
ilim.isnumber = true
ilim.datatype = "and(uinteger,min(0))"
ilim.rmempty = true
ilim:depends("qdisc_really_really_advanced", "1")

elim = s:taboption("tab_qdisc", Value, "elimit", translate("Hard limit on egress queues; leave empty for default."))
-- elim.default = 1000
elim.datatype = "and(uinteger,min(0))"
elim.rmempty = true
elim:depends("qdisc_really_really_advanced", "1")


itarg = s:taboption("tab_qdisc", Value, "itarget", translate("Latency target for ingress, e.g 5ms [units: s, ms, or  us]; leave empty for automatic selection, put in the word default for the qdisc's default."))
itarg.datatype = "string"
itarg.rmempty = true
itarg:depends("qdisc_really_really_advanced", "1")

etarg = s:taboption("tab_qdisc", Value, "etarget", translate("Latency target for egress, e.g. 5ms [units: s, ms, or  us]; leave empty for automatic selection, put in the word default for the qdisc's default."))
etarg.datatype = "string"
etarg.rmempty = true
etarg:depends("qdisc_really_really_advanced", "1")



iqdisc_opts = s:taboption("tab_qdisc", Value, "iqdisc_opts", translate("Advanced option string to pass to the ingress queueing disciplines; no error checking, use very carefully."))
iqdisc_opts.rmempty = true
iqdisc_opts:depends("qdisc_really_really_advanced", "1")

eqdisc_opts = s:taboption("tab_qdisc", Value, "eqdisc_opts", translate("Advanced option string to pass to the egress queueing disciplines; no error checking, use very carefully."))
eqdisc_opts.rmempty = true
eqdisc_opts:depends("qdisc_really_really_advanced", "1")

-- LINKLAYER
ll = s:taboption("tab_linklayer", ListValue, "linklayer", translate("Which link layer to account for:"))
ll:value("none", "none ("..translate("default")..")")
ll:value("ethernet", "Ethernet with overhead: select for e.g. VDSL2.")
ll:value("atm", "ATM: select for e.g. ADSL1, ADSL2, ADSL2+.")
-- ll:value("adsl")	-- reduce the options
ll.default = "none"

po = s:taboption("tab_linklayer", Value, "overhead", translate("Per Packet Overhead (byte):"))
po.datatype = "and(integer,min(-1500))"
po.default = 0
po.isnumber = true
po.rmempty = true
po:depends("linklayer", "ethernet")
-- po:depends("linklayer", "adsl")
po:depends("linklayer", "atm")


adll = s:taboption("tab_linklayer", Flag, "linklayer_advanced", translate("Show Advanced Linklayer Options, (only needed if MTU > 1500)"))
adll.rmempty = true
adll:depends("linklayer", "ethernet")
-- adll:depends("linklayer", "adsl")
adll:depends("linklayer", "atm")

smtu = s:taboption("tab_linklayer", Value, "tcMTU", translate("Maximal Size for size and rate calculations, tcMTU (byte); needs to be >= interface MTU + overhead:"))
smtu.datatype = "and(uinteger,min(0))"
smtu.default = 2047
smtu.isnumber = true
smtu.rmempty = true
smtu:depends("linklayer_advanced", "1")

stsize = s:taboption("tab_linklayer", Value, "tcTSIZE", translate("Number of entries in size/rate tables, TSIZE; for ATM choose TSIZE = (tcMTU + 1) / 16:"))
stsize.datatype = "and(uinteger,min(0))"
stsize.default = 128
stsize.isnumber = true
stsize.rmempty = true
stsize:depends("linklayer_advanced", "1")

smpu = s:taboption("tab_linklayer", Value, "tcMPU", translate("Minimal packet size, MPU (byte); needs to be > 0 for ethernet size tables:"))
smpu.datatype = "and(uinteger,min(0))"
smpu.default = 0
smpu.isnumber = true
smpu.rmempty = true
smpu:depends("linklayer_advanced", "1")

lla = s:taboption("tab_linklayer", ListValue, "linklayer_adaptation_mechanism", translate("Which linklayer adaptation mechanism to use; for testing only"))
lla:value("htb_private")
lla:value("tc_stab", "tc_stab ("..translate("default")..")")
lla.default = "tc_stab"
lla.rmempty = true
lla:depends("linklayer_advanced", "1")

-- PRORITIES?

return m
