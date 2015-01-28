--[[

LuCI DansGuardian module

Copyright (C) 2015, Itus Networks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Author: Luka Perkov <luka@openwrt.org>

]]--

local fs = require "nixio.fs"

m = Map("dansguardian", translate("DansGuardian"))
m.on_after_commit = function() luci.sys.call("/etc/init.d/dansguardian restart") end

s = m:section(TypedSection, "dansguardian")
s.anonymous = true
s.addremove = false

s:tab("general", translate("General Settings"))
s:tab("additional", translate("Additional Settings"))
s:tab("log", translate("Log"))

filterip = s:taboption("general", Value, "filterip", translate("IP that DansGuardian listens"))
filterip.datatype = "ip4addr"

filterports = s:taboption("general", Value, "filterports", translate("Port that DansGuardian listens"))
filterports.datatype = "portrange"
filterports.placeholder = "0-65535"

proxyip = s:taboption("general", Value, "proxyip", translate("IP address of the proxy"))
proxyip.datatype = "ip4addr"
proxyip.default = "127.0.0.1"

proxyport = s:taboption("general", Value, "proxyport", translate("Port of the proxy"))
proxyport.datatype = "portrange"
proxyport.placeholder = "0-65535"

reportinglevel = s:taboption("general", ListValue, "reportinglevel", translate("Web access denied reporting"))
reportinglevel:value("-1",  translate("log only"))
reportinglevel:value("0",  translate("say Access Denied"))
reportinglevel:value("1",  translate("report why but not what denied phrase"))
reportinglevel:value("2",  translate("report fully"))
reportinglevel:value("3",  translate("use HTML template"))
reportinglevel.default = "3"

languagedir = s:taboption("general", Value, "languagedir", translate("Language dir"))
languagedir.datatype = "string"
languagedir.default = "/usr/share/dansguardian/languages"

language = s:taboption("general", Value, "language", translate("Language to use"))
language.datatype = "string"
language.default = "ukenglish"

loglevel = s:taboption("general", ListValue, "loglevel", translate("Logging Settings"))
loglevel:value("0",  translate("none"))
loglevel:value("1",  translate("just denied"))
loglevel:value("2",  translate("all text based"))
loglevel:value("3",  translate("all requests"))
loglevel.default = "2"

logexceptionhits = s:taboption("general", ListValue, "logexceptionhits", translate("Log Exception Hits"))
logexceptionhits:value("0",  translate("never log"))
logexceptionhits:value("1",  translate("log, don't mark as exceptions"))
logexceptionhits:value("2",  translate("log & mark"))
logexceptionhits.default = "2"

logfileformat = s:taboption("general", ListValue, "logfileformat", translate("Log File Format"))
logfileformat:value("1",  translate("DansGuardian (space delimited)"))
logfileformat:value("2",  translate("CSV"))
logfileformat:value("3",  translate("Squid Log File"))
logfileformat:value("4",  translate("Tab delimited"))
logfileformat.default = "1"

logsyslog = s:taboption("general", ListValue, "logsyslog", translate("Syslog logging"))
logsyslog:value("on",  translate("Yes"))
logsyslog:value("off",  translate("No"))
logsyslog.default = "on"

statloaction = s:taboption("general", Value, "statlocation", translate("Statistics file location"),
	translate("Only used in with maxips > 0"))
statloaction.datatype = "string"
statloaction.default = "/var/log/dansguardian/stats"

accessdeniedaddress = s:taboption("general", Value, "accessdeniedaddress", translate("Access denied address"),
	translate("Server to which the cgi dansguardian reporting script was copied. Reporting levels 1 and 2 only"))
accessdeniedaddress.datatype = "string"
accessdeniedaddress.default = "http://YOURSERVER.YOURDOMAIN/cgi-bin/dansguardian.pl"

nonstandarddelimiter = s:taboption("general", ListValue, "nonstandarddelimiter", translate("Non standard delimiter"),
	translate("To preserve the full banned URL, only use with the access denied address"))
nonstandarddelimiter:value("on",  translate("Yes"))
nonstandarddelimiter:value("off",  translate("No"))
nonstandarddelimiter.default = "on"

usecustombannedimage = s:taboption("general", ListValue, "usecustombannedimage", translate("Banned image replacement"))
usecustombannedimage:value("on",  translate("Yes"))
usecustombannedimage:value("off",  translate("No"))
usecustombannedimage.default = "on"

custombannedimagefile = s:taboption("general", Value, "custombannedimagefile", translate("Custom banned image file"))
custombannedimagefile.datatype = "string"
custombannedimagefile.default = "/usr/share/dansguardian/transparent1x1.gif"

usecustombannedflash = s:taboption("general", ListValue, "usecustombannedflash", translate("Banned flash replacement"))
usecustombannedflash:value("on",  translate("Yes"))
usecustombannedflash:value("off",  translate("No"))
usecustombannedflash.default = "on"

custombannedflashfile = s:taboption("general", Value, "custombannedflashfile", translate("Custom banned flash file"))
custombannedflashfile.datatype = "string"
custombannedflashfile.default = "/usr/share/dansguardian/blockedflash.swf"

filtergroups = s:taboption("general", Value, "filtergroups", translate("Number of filter groups"))
filtergroups.datatype = "and(uinteger,min(1))"
filtergroups.default = "1"

filtergroupslist = s:taboption("general", Value, "filtergroupslist", translate("List of filter groups"))
filtergroupslist.datatype = "string"
filtergroupslist.default = "/etc/dansguardian/lists/filtergroupslist"

bannediplist = s:taboption("general", Value, "bannediplist", translate("List of banned IPs"))
bannediplist.datatype = "string"
bannediplist.default = "/etc/dansguardian/lists/bannediplist"

exceptioniplist = s:taboption("general", Value, "exceptioniplist", translate("List of IP exceptions"))
exceptioniplist.datatype = "string"
exceptioniplist.default = "/etc/dansguardian/lists/exceptioniplist"


perroomblockingdirectory = s:taboption("general", Value, "perroomblockingdirectory", translate("Per-Room blocking definition directory"))
perroomblockingdirectory.datatype = "string"
perroomblockingdirectory.default = "/etc/dansguardian/lists/bannedrooms/"

showweightedfound = s:taboption("general", ListValue, "showweightedfound", translate("Show weighted phrases found"))
showweightedfound:value("on",  translate("Yes"))
showweightedfound:value("off",  translate("No"))
showweightedfound.default = "on"

weightedphrasemode = s:taboption("general", ListValue, "weightedphrasemode", translate("Weighted phrase mode"))
weightedphrasemode:value("0",  translate("off"))
weightedphrasemode:value("1",  translate("on, normal phrase operation"))
weightedphrasemode:value("2",  translate("on, phrase found only counts once on a page"))
weightedphrasemode.default = "2"

urlcachenumber = s:taboption("general", Value, "urlcachenumber", translate("Clean result caching for URLs"))
urlcachenumber.datatype = "and(uinteger,min(0))"
urlcachenumber.default = "1000"

urlcacheage = s:taboption("general", Value, "urlcacheage", translate("Age before they should be ignored in seconds"))
urlcacheage.datatype = "and(uinteger,min(0))"
urlcacheage.default = "900"

scancleancache = s:taboption("general", ListValue, "scancleancache", translate("Cache for content (AV) scans as 'clean'"))
scancleancache:value("on",  translate("Yes"))
scancleancache:value("off",  translate("No"))
scancleancache.default = "on"

phrasefiltermode = s:taboption("general", ListValue, "phrasefiltermode", translate("Filtering options"))
phrasefiltermode:value("0",  translate("raw"))
phrasefiltermode:value("1",  translate("smart"))
phrasefiltermode:value("2",  translate("raw & smart"))
phrasefiltermode:value("3",  translate("meta/title"))
phrasefiltermode.default = "2"

preservecase = s:taboption("general", ListValue, "perservecase", translate("Lower caseing options"))
preservecase:value("0",  translate("force lower case"))
preservecase:value("1",  translate("dont change"))
preservecase:value("2",  translate("scan in lower case, then in original case"))
preservecase.default = "0"

hexdecodecontent = s:taboption("general", ListValue, "hexdecodecontent", translate("Hex decoding options"))
hexdecodecontent:value("on",  translate("Yes"))
hexdecodecontent:value("off",  translate("No"))
hexdecodecontent.default = "off"

forcequicksearch = s:taboption("general", ListValue, "forcequicksearch", translate("Quick search"))
forcequicksearch:value("on",  translate("Yes"))
forcequicksearch:value("off",  translate("No"))
forcequicksearch.default = "off"

reverseaddresslookups= s:taboption("general", ListValue, "reverseaddresslookups", translate("Reverse lookups for banned site and URLs"))
reverseaddresslookups:value("on",  translate("Yes"))
reverseaddresslookups:value("off",  translate("No"))
reverseaddresslookups.default = "off"

reverseclientiplookups = s:taboption("general", ListValue, "reverseclientiplookups", translate("Reverse lookups for banned and exception IP lists"))
reverseclientiplookups:value("on",  translate("Yes"))
reverseclientiplookups:value("off",  translate("No"))
reverseclientiplookups.default = "off"

logclienthostnames = s:taboption("general", ListValue, "logclienthostnames", translate("Perform reverse lookups on client IPs for successful requests"))
logclienthostnames:value("on",  translate("Yes"))
logclienthostnames:value("off",  translate("No"))
logclienthostnames.default = "off"

createlistcachefiles = s:taboption("general", ListValue, "createlistcachefiles", translate("Build bannedsitelist and bannedurllist cache files"))
createlistcachefiles:value("on",translate("Yes"))
createlistcachefiles:value("off",translate("No"))
createlistcachefiles.default = "on"

prefercachedlists = s:taboption("general", ListValue, "prefercachedlists", translate("Prefer cached list files"))
prefercachedlists:value("on",  translate("Yes"))
prefercachedlists:value("off",  translate("No"))
prefercachedlists.default = "off"

maxuploadsize = s:taboption("general", Value, "maxuploadsize", translate("Max upload size (in Kbytes)"))
maxuploadsize:value("-1",  translate("no blocking"))
maxuploadsize:value("0",  translate("complete block"))
maxuploadsize.default = "-1"

maxcontentfiltersize = s:taboption("general", Value, "maxcontentfiltersize", translate("Max content filter size"),
	translate("The value must not be higher than max content ram cache scan size or 0 to match it"))
maxcontentfiltersize.datatype = "and(uinteger,min(0))"
maxcontentfiltersize.default = "256"

maxcontentramcachescansize = s:taboption("general", Value, "maxcontentramcachescansize", translate("Max content ram cache scan size"),
	translate("This is the max size of file that DG will download and cache in RAM"))
maxcontentramcachescansize.datatype = "and(uinteger,min(0))"
maxcontentramcachescansize.default = "2000"

maxcontentfilecachescansize = s:taboption("general", Value, "maxcontentfilecachescansize", translate("Max content file cache scan size"))
maxcontentfilecachescansize.datatype = "and(uinteger,min(0))"
maxcontentfilecachescansize.default = "2000"

proxytimeout = s:taboption("general", Value, "proxytimeout", translate("Proxy timeout"))
proxytimeout.datatype = "range(20,30)"
proxytimeout.default = "20"

filecachedir = s:taboption("general", Value, "filecachedir", translate("File cache directory"))
filecachedir.datatype = "string"
filecachedir.default = "/tmp"

deletedownloadedtempfiles = s:taboption("general", ListValue, "deletedownloadedtempfiles", translate("Delete file cache after user completes download"))
deletedownloadedtempfiles:value("on",  translate("Yes"))
deletedownloadedtempfiles:value("off", translate("No"))
deletedownloadedtempfiles.default = "on"

initialtrickledelay = s:taboption("general", Value, "initialtrickledelay", translate("Initial Trickle delay"),
	translate("Number of seconds a browser connection is left waiting before first being sent *something* to keep it alive"))
initialtrickledelay.datatype = "and(uinteger,min(0))"
initialtrickledelay.default = "20"

trickledelay = s:taboption("general", Value, "trickledelay", translate("Trickle delay"),
	translate("Number of seconds a browser connection is left waiting before being sent more *something* to keep it alive"))
trickledelay.datatype = "and(uinteger,min(0))"
trickledelay.default = "10"

downloadmanager = s:taboption("general", Value, "downloadmanager", translate("Download manager"))
downloadmanager.datatype = "string"
downloadmanager.default = "/etc/dansguardian/downloadmanagers/default.conf"

contentscannertimeout = s:taboption("general", Value, "contentscannertimeout", translate("Content scanner timeout"))
contentscannertimeout.datatype = "and(uinteger,min(0))"
contentscannertimeout.default = "60"

contentscanexceptions = s:taboption("general", ListValue, "contentscanexceptions", translate("Content scan exceptions"))
contentscanexceptions:value("on",  translate("Yes"))
contentscanexceptions:value("off", translate("No"))
contentscanexceptions.default = "off"

recheckreplacedurls = s:taboption("general", ListValue, "recheckreplacedurls", translate("e-check replaced URLs"))
recheckreplacedurls:value("on",  translate("Yes"))
recheckreplacedurls:value("off", translate("No"))
recheckreplacedurls.default = "off"

forwardedfor = s:taboption("general", ListValue, "forwardedfor", translate("Misc setting: forwardedfor"),
	translate("If on, it may help solve some problem sites that need to know the source ip."))
forwardedfor:value("on",  translate("Yes"))
forwardedfor:value("off", translate("No"))
forwardedfor.default = "off"

usexforwardedfor = s:taboption("general", ListValue, "usexforwardedfor", translate("Misc setting: usexforwardedfor"),
	translate("This is for when you have squid between the clients and DansGuardian"))
usexforwardedfor:value("on",  translate("Yes"))
usexforwardedfor:value("off", translate("No"))
usexforwardedfor.default = "off"

logconnectionhandlingerrors = s:taboption("general", ListValue, "logconnectionhandlingerrors", translate("Log debug info about log()ing and accept()ing"))
logconnectionhandlingerrors:value("on",  translate("Yes"))
logconnectionhandlingerrors:value("off", translate("No"))
logconnectionhandlingerrors.default = "on"

logchildprocesshandling = s:taboption("general", ListValue, "logchildprocesshandling", translate("Log child process handling"))
logchildprocesshandling:value("on",  translate("Yes"))
logchildprocesshandling:value("off", translate("No"))
logchildprocesshandling.default = "off"

maxchildren = s:taboption("general", Value, "maxchildren", translate("Max number of processes to spawn"))
maxchildren.datatype = "and(uinteger,min(0))"
maxchildren.default = "32"

minchildren = s:taboption("general", Value, "minchildren", translate("Min number of processes to spawn"))
minchildren.datatype = "and(uinteger,min(0))"
minchildren.default = "8"

minsparechildren = s:taboption("general", Value, "minsparechildren", translate("Min number of processes to keep ready"))
minsparechildren.datatype = "and(uinteger,min(0))"
minsparechildren.default = "4"

preforkchildren = s:taboption("general", Value, "preforkchildren", translate("Sets minimum nuber of processes when it runs out"))
preforkchildren.datatype = "and(uinteger,min(0))"
preforkchildren.default = "6"

maxsparechildren = s:taboption("general", Value, "maxsparechildren", translate("Sets the maximum number of processes to have doing nothing"))
maxsparechildren.datatype = "and(uinteger,min(0))"
maxsparechildren.default = "32"

maxagechildren = s:taboption("general", Value, "maxagechildren", translate("Max age of child process"))
maxagechildren.datatype = "and(uinteger,min(0))"
maxagechildren.default = "500"

maxips = s:taboption("general", Value, "maxips", translate("Max number of clinets allowed to connect"))
maxips:value("0",  translate("no limit"))
maxips.default = "0"

ipipcfilename = s:taboption("general", Value, "ipipcfilename", translate("IP list IPC server directory and filename"))
ipipcfilename.datatype = "string"
ipipcfilename.default = "/tmp/.dguardianipipc"

nodeamon = s:taboption("general", ListValue, "nodeamon", translate("Disable deamoning"))
nodeamon:value("on",  translate("Yes"))
nodeamon:value("off", translate("No"))
nodeamon.default = "off"

nologger = s:taboption("general", ListValue, "nologger", translate("Disable logger"))
nologger:value("on",  translate("Yes"))
nologger:value("off", translate("No"))
nologger.default = "off"

logadblock = s:taboption("general", ListValue, "logadblock", translate("Enable loging of ADs"))
logadblock:value("on",  translate("Yes"))
logadblock:value("off", translate("No"))
logadblock.default = "off"

loguseragent = s:taboption("general", ListValue, "loguseragent", translate("Enable loggin of client user agent"))
loguseragent:value("on",  translate("Yes"))
loguseragent:value("off", translate("No"))
loguseragent.default = "off"

softrestart = s:taboption("general", ListValue, "softrestart", translate("Enable soft restart"))
softrestart:value("on",  translate("Yes"))
softrestart:value("off", translate("No"))
softrestart.default = "off"

dansguardian_config_file = s:taboption("additional", TextValue, "_data", "")
dansguardian_config_file.wrap = "off"
dansguardian_config_file.rows = 25
dansguardian_config_file.rmempty = false

function dansguardian_config_file.cfgvalue()
	local uci = require "luci.model.uci".cursor_state()
	local file = uci:get("dansguardian", "dansguardian", "config_file")
	if file then
		return fs.readfile(file) or ""
	else
		return ""
	end
end

function dansguardian_config_file.write(self, section, value)
	if value then
		local uci = require "luci.model.uci".cursor_state()
		local file = uci:get("dansguardian", "dansguardian", "config_file")
		fs.writefile(file, value:gsub("\r\n", "\n"))
	end
end


dansguardian_logfile = s:taboption("log", TextValue, "lines", "")
dansguardian_logfile.wrap = "off"
dansguardian_logfile.rows = 25
dansguardian_logfile.rmempty = true

function dansguardian_logfile.cfgvalue()
	local uci = require "luci.model.uci".cursor_state()
	local file = "/tmp/dansguardian/access.log"
	if file then
		return fs.readfile(file) or ""
	else
		return ""
	end
end

return m
