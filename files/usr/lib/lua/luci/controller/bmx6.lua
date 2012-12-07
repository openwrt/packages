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

local bmx6json = require("luci.model.bmx6json")

module("luci.controller.bmx6", package.seeall)

function index()
	local place = {}
	local ucim = require "luci.model.uci"
	local uci = ucim.cursor()
	-- checking if ignore is on
	if uci:get("luci-bmx6","luci","ignore") == "1" then
		return nil
	end

	-- getting value from uci database
	local uci_place = uci:get("luci-bmx6","luci","place")

	-- default values
	if uci_place == nil then
		place = {"bmx6"}
	else
		local util = require "luci.util"
		place = util.split(uci_place," ")
	end
	---------------------------
	-- Starting with the pages
	---------------------------

	--- neighbours/descriptions (default)
	entry(place,call("action_neighbours_j"),place[#place])

	table.insert(place,"neighbours_nojs")
	entry(place, call("action_neighbours"), nil)
	table.remove(place)

	--- status (this is default one)
	table.insert(place,"Status")
	entry(place,call("action_status"),"Status")
	table.remove(place)

	--- links
	table.insert(place,"Links")
	entry(place,call("action_links"),"Links").leaf = true
	table.remove(place)

	-- Gateways
	table.insert(place,"Gateways")
	entry(place,call("action_gateways_j"),"Gateways").leaf = true
	table.remove(place)

	--- chat
	table.insert(place,"Chat")
	entry(place,call("action_chat"),"Chat")
	table.remove(place)

	--- Graph
	table.insert(place,"Graph")
	entry(place, template("bmx6/graph"), "Graph")
	table.remove(place)

	--- Topology (hidden)
	table.insert(place,"topology")
	entry(place, call("action_topology"), nil)
	table.remove(place)

	--- configuration (CBI)
	table.insert(place,"Configuration")
	entry(place, cbi("bmx6/main"), "Configuration").dependent=false

	table.insert(place,"Advanced")
	entry(place, cbi("bmx6/advanced"), "Advanced")
	table.remove(place)

	table.insert(place,"Interfaces")
	entry(place, cbi("bmx6/interfaces"), "Interfaces")
	table.remove(place)

	table.insert(place,"Plugins")
	entry(place, cbi("bmx6/plugins"), "Plugins")
	table.remove(place)

	table.insert(place,"HNA")
	entry(place, cbi("bmx6/hna"), "HNA")
	table.remove(place)

	table.remove(place)

end

function action_status()
		local status = bmx6json.get("status").status or nil
		local interfaces = bmx6json.get("interfaces").interfaces or nil

		if status == nil or interfaces == nil then
			luci.template.render("bmx6/error", {txt="Cannot fetch data from bmx6 json"})
		else
        	luci.template.render("bmx6/status", {status=status,interfaces=interfaces})
		end
end

function action_neighbours()
		local orig_list = bmx6json.get("originators").originators or nil

		if orig_list == nil then
			luci.template.render("bmx6/error", {txt="Cannot fetch data from bmx6 json"})
			return nil
		end

		local originators = {}
		local desc = nil
		local orig = nil
		local name = ""
		local ipv4 = ""

		for _,o in ipairs(orig_list) do
			orig = bmx6json.get("originators/"..o.name) or {}
			desc = bmx6json.get("descriptions/"..o.name) or {}

			if string.find(o.name,'.') then
				name = luci.util.split(o.name,'.')[1]
			else
				name = o.name
			end

			--Not sure about that, but trying to find main ipv4 from HNA6 published by each node
			if desc.DESC_ADV ~= nil then
				for _,h in ipairs(desc.DESC_ADV.extensions[2].HNA6_EXTENSION) do

					if h ~= nil and  string.find(h.address,"::ffff:") then
						ipv4=string.gsub(h.address,"::ffff:","")
						break
					end
				end
			end

			if ipv4 == "" then
				ipv4="0.0.0.0"
			end

			table.insert(originators,{name=name,ipv4=ipv4,orig=orig,desc=desc})
		end

        luci.template.render("bmx6/neighbours", {originators=originators})
end

function action_neighbours_j()
	local http = require "luci.http"
	local link_non_js = "/cgi-bin/luci" .. http.getenv("PATH_INFO") .. '/neighbours_nojs'

	luci.template.render("bmx6/neighbours_j", {link_non_js=link_non_js})
end

function action_gateways_j()
	luci.template.render("bmx6/gateways_j", {})
end


function action_links(host)
	local links = bmx6json.get("links", host)
	local devlinks = {}
	local _,l

	if links ~= nil then
		links = links.links
		for _,l in ipairs(links) do
			devlinks[l.viaDev] = {}
		end
		for _,l in ipairs(links) do
			l.globalId = luci.util.split(l.globalId,'.')[1]
			table.insert(devlinks[l.viaDev],l)
		end
	end

	luci.template.render("bmx6/links", {links=devlinks})
end

function action_topology()
	local originators = bmx6json.get("originators/all")
	local o,i,l,i2
	local first = true
	luci.http.prepare_content("application/json")
	luci.http.write('[ ')

	for i,o in ipairs(originators) do
		local links = bmx6json.get("links",o.primaryIp)
		if links then
			if first then
				first = false
			else
				luci.http.write(', ')
			end

			luci.http.write('{ "globalId": "%s", "links": [' %o.globalId:match("^[^%.]+"))

			local first2 = true

			for i2,l in ipairs(links.links) do
				if first2 then
					first2 = false
				else
					luci.http.write(', ')
				end

				luci.http.write('{ "globalId": "%s", "rxRate": %s, "txRate": %s }'
					%{ l.globalId:match("^[^%.]+"), l.rxRate, l.txRate })

			end

			luci.http.write(']}')
		end

	end
	luci.http.write(' ]')
end


function action_chat()
	local sms_dir = "/var/run/bmx6/sms"
	local rcvd_dir = sms_dir .. "/rcvdSms"
	local send_file = sms_dir .. "/sendSms/chat"
	local sms_list = bmx6json.get("rcvdSms")
	local sender = ""
	local sms_file = ""
	local chat = {}
	local to_send = nil
	local sent = ""
	local fd = nil

	if luci.sys.call("test -d " .. sms_dir) ~= 0 then
		luci.template.render("bmx6/error", {txt="sms plugin disabled or some problem with directory " .. sms_dir})
		return nil
	end

	sms_list = luci.util.split(luci.util.exec("ls "..rcvd_dir.."/*:chat"))

	for _,sms_path in ipairs(sms_list) do
	  if #sms_path > #rcvd_dir then
		sms_file = luci.util.split(sms_path,'/')
		sms_file = sms_file[#sms_file]
		sender = luci.util.split(sms_file,':')[1]

		-- Trying to clean the name
		if string.find(sender,".") ~= nil then
			sender = luci.util.split(sender,".")[1]
		end

		fd = io.open(sms_path,"r")
		chat[sender] = fd:read()
		fd:close()
	  end
	end

	to_send = luci.http.formvalue("toSend")
	if to_send ~= nil and #to_send > 1  then
		fd = io.open(send_file,"w")
		fd:write(to_send)
		fd:close()
		sent = to_send
	else
		sent = luci.util.exec("cat "..send_file)
	end

	luci.template.render("bmx6/chat", {chat=chat,sent=sent})
end

