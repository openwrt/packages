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

	-- getting position of menu
	local uci_position = uci:get("luci-bmx6","luci","position")

	---------------------------
	-- Starting with the pages
	---------------------------

	--- status (default)
	entry(place,call("action_nodes_j"),place[#place],tonumber(uci_position))            

	table.insert(place,"Status")
	entry(place,call("action_status_j"),"Status",0)
	table.remove(place)

	--- nodes
	table.insert(place,"Nodes")
	entry(place,call("action_nodes_j"),"Nodes",1)
	table.remove(place)

	--- links
	table.insert(place,"Links")
	entry(place,call("action_links"),"Links",2).leaf = true
	table.remove(place)

	-- Tunnels
	table.insert(place,"Tunnels")
	entry(place,call("action_tunnels_j"), "Tunnels", 3).leaf = true
	table.remove(place)

	--- Chat
	table.insert(place,"Chat")
	entry(place,call("action_chat"),"Chat",5)
	table.remove(place)

	--- Graph
	table.insert(place,"Graph")
	entry(place, template("bmx6/graph"), "Graph",4)
	table.remove(place)

	--- Topology (hidden)
	table.insert(place,"topology")
	entry(place, call("action_topology"), nil)
	table.remove(place)

	--- configuration (CBI)
	table.insert(place,"Configuration")
	entry(place, cbi("bmx6/main"), "Configuration",6).dependent=false

	table.insert(place,"General")
	entry(place, cbi("bmx6/main"), "General",1)
	table.remove(place)

	table.insert(place,"Advanced")
	entry(place, cbi("bmx6/advanced"), "Advanced",5)
	table.remove(place)

	table.insert(place,"Interfaces")
	entry(place, cbi("bmx6/interfaces"), "Interfaces",2)
	table.remove(place)

	table.insert(place,"Tunnels")
        entry(place, cbi("bmx6/tunnels"), "Tunnels",3)
        table.remove(place)

	table.insert(place,"Plugins")
	entry(place, cbi("bmx6/plugins"), "Plugins",6)
	table.remove(place)

	table.insert(place,"HNAv6")
	entry(place, cbi("bmx6/hna"), "HNAv6",4)
	table.remove(place)

	table.remove(place)

end

function action_status_j()
	luci.template.render("bmx6/status_j", {})
end


function action_nodes_j()
	local http = require "luci.http"
	local link_non_js = "/cgi-bin/luci" .. http.getenv("PATH_INFO") .. '/nodes_nojs'

	luci.template.render("bmx6/nodes_j", {link_non_js=link_non_js})
end

function action_gateways_j()
	luci.template.render("bmx6/gateways_j", {})
end

function action_tunnels_j()
        luci.template.render("bmx6/tunnels_j", {})
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
			l.name = luci.util.split(l.name,'.')[1]
			table.insert(devlinks[l.viaDev],l)
		end
	end

	luci.template.render("bmx6/links", {links=devlinks})
end

function action_topology()
	local originators = bmx6json.get("originators/all")
	local o,i,l,i2
	local first = true
	local topology = '[ '
	local cache = '/tmp/bmx6-topology.json'
	local offset = 60

	local cachefd = io.open(cache,r)
	local update = false

	if cachefd ~= nil then
		local lastupdate = tonumber(cachefd:read("*line")) or 0
		if os.time() >= lastupdate + offset then
			update = true
		else
			topology = cachefd:read("*all")
		end
		cachefd:close()
	end

	if cachefd == nil or update then
	    	for i,o in ipairs(originators) do
	    		local links = bmx6json.get("links",o.primaryIp)
	    		if links then
	    			if first then
	    				first = false
	    			else
						topology = topology .. ', '
	    			end
	    
					topology = topology .. '{ "name": "%s", "links": [' %o.name
	    
	    			local first2 = true
	    
	    			for i2,l in ipairs(links.links) do
	    				if first2 then
	    					first2 = false
	    				else
	    					topology = topology .. ', '
						end
						name = l.name or l.llocalIp or "unknown"
						topology = topology .. '{ "name": "%s", "rxRate": %s, "txRate": %s }'
							%{ name, l.rxRate, l.txRate }
	    
	    			end
	    
	    			topology = topology .. ']}'
	    		end
	    
	    	end
		
		topology = topology .. ' ]'

		-- Upgrading the content of the cache file
	 	cachefd = io.open(cache,'w+')
		cachefd:write(os.time()..'\n')
		cachefd:write(topology)
		cachefd:close()
	end

	luci.http.prepare_content("application/json")
	luci.http.write(topology)
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

