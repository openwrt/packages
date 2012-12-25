--[[
    Copyright (C) 2011 Pau Escrich <pau@dabax.net>
    Contributors Jo-Philipp Wich <xm@subsignal.org>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

    The full GNU General Public License is included in this distribution in
    the file called "COPYING".
--]]

local ltn12 = require("luci.ltn12")
local json = require("luci.json")
local util = require("luci.util")
local uci = require("luci.model.uci")
local sys = require("luci.sys")
local template = require("luci.template")
local http = require("luci.http")
local string = require("string")
local table = require("table")
local nixio = require("nixio")
local nixiofs = require("nixio.fs")
local ipairs = ipairs

module "luci.model.bmx6json"

-- Returns a LUA object from bmx6 JSON daemon

function get(field, host)
	local url
	if host ~= nil then
		if host:match(":") then
			url = 'http://[%s]/cgi-bin/bmx6-info?' % host
		else
			url = 'http://%s/cgi-bin/bmx6-info?' % host
		end
	else
		url = uci.cursor():get("luci-bmx6","luci","json")
	end

	if url == nil then
		 print_error("bmx6 json url not configured, cannot fetch bmx6 daemon data",true)
		 return nil
	 end

	 local json_url = util.split(url,":")
	 local raw = ""

	if json_url[1] == "http"  then
		raw,err = wget(url..field,1000)
	else

		if json_url[1] == "exec" then
			raw = sys.exec(json_url[2]..' '..field)
		else
			print_error("bmx6 json url not recognized, cannot fetch bmx6 daemon data. Use http: or exec:",true)
			return nil
		end

	end

	local data = nil

	if raw and raw:len() > 10 then
		local decoder = json.Decoder()
		ltn12.pump.all(ltn12.source.string(raw), decoder:sink())
		data = decoder:get()
--	else
--		print_error("Cannot get data from bmx6 daemon",true)
--		return nil
	end

	return data
end

function print_error(txt,popup)
	util.perror(txt)
	sys.call("logger -t bmx6json " .. txt)

	if popup then
		http.write('<script type="text/javascript">alert("Some error detected, please check it: '..txt..'");</script>')
	else
		http.write("<h1>Dammit! some error detected</h1>")
		http.write("bmx6-luci: " .. txt)
		http.write('<p><FORM><INPUT TYPE="BUTTON" VALUE="Go Back" ONCLICK="history.go(-1)"></FORM></p>')
	end

end

function text2html(txt)
	txt = string.gsub(txt,"<","{")
	txt = string.gsub(txt,">","}")
	txt = util.striptags(txt)
	return txt
end


function wget(url, timeout)
	local rfd, wfd = nixio.pipe()
	local pid = nixio.fork()
	if pid == 0 then
		rfd:close()
		nixio.dup(wfd, nixio.stdout)

		local candidates = { "/usr/bin/wget", "/bin/wget" }
		local _, bin
		for _, bin in ipairs(candidates) do
			if nixiofs.access(bin, "x") then
				nixio.exec(bin, "-q", "-O", "-", url)
			end
		end
		return
	else
		wfd:close()
		rfd:setblocking(false)

		local buffer = { }
		local err1, err2

		while true do
			local ready = nixio.poll({{ fd = rfd, events = nixio.poll_flags("in") }}, timeout)
			if not ready then
				nixio.kill(pid, nixio.const.SIGKILL)
				err1 = "timeout"
				break
			end

			local rv = rfd:read(4096)
			if rv then
				-- eof
				if #rv == 0 then
					break
				end

				buffer[#buffer+1] = rv
			else
				-- error
				if nixio.errno() ~= nixio.const.EAGAIN and
				   nixio.errno() ~= nixio.const.EWOULDBLOCK then
				   	err1 = "error"
				   	err2 = nixio.errno()
				end
			end
		end

		nixio.waitpid(pid, "nohang")
		if not err1 then
			return table.concat(buffer)
		else
			return nil, err1, err2
		end
	end
end

function getOptions(name)
	-- Getting json and Checking if bmx6-json is avaiable
	local options = get("options")
	if options == nil or options.OPTIONS == nil then
		m.message = "bmx6-json plugin is not running or some mistake in luci-bmx6 configuration, check /etc/config/luci-bmx6"
		return nil
	else
		options = options.OPTIONS
	end

	-- Filtering by the option name
	local i,_
	local namedopt = nil
	if name ~= nil then
		for _,i in ipairs(options) do
			if i.name == name and i.CHILD_OPTIONS ~= nil then
				namedopt = i.CHILD_OPTIONS
				break
			end
		end
	end

	return namedopt
end

-- Rturns a help string formated to be used in HTML scope
function getHtmlHelp(opt)
	if opt == nil then return nil end
	
	local help = ""
	if opt.help ~= nil then
		help = text2html(opt.help)
	end
	if opt.syntax ~= nil then
		help = help .. "<br/><b>Syntax: </b>" .. text2html(opt.syntax)
	end		

	return help
end

function testandreload()
	local test = sys.call('bmx6 -c --test > /tmp/bmx6-luci.err.tmp')
	if test ~= 0 then
		return sys.exec("cat /tmp/bmx6-luci.err.tmp")
	end

	local err = sys.call('bmx6 -c --configReload > /tmp/bmx6-luci.err.tmp')
		if err ~= 0 then
		return sys.exec("cat /tmp/bmx6-luci.err.tmp")
	end

	return nil
end

