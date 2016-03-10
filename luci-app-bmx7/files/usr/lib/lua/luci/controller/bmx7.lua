--[[
    Copyright (C) 2011 Pau Escrich <pau@dabax.net>
    Contributors Jo-Philipp Wich <xm@subsignal.org>
                 Roger Pueyo Centelles <roger.pueyo@guifi.net>

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

module("luci.controller.bmx7", package.seeall)

function index()
	local place = {}
	local ucim = require "luci.model.uci"
	local uci = ucim.cursor()

	-- checking if ignore is on
	if uci:get("luci-bmx7","luci","ignore") == "1" then
		return nil
	end

	-- getting value from uci database
	local uci_place = uci:get("luci-bmx7","luci","place")

	-- default values
	if uci_place == nil then
		place = {"bmx7"}
	else
		local util = require "luci.util"
		place = util.split(uci_place," ")
	end

	-- getting position of menu
	local uci_position = uci:get("luci-bmx7","luci","position")

end