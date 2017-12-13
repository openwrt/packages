--[[ 
Copyright (C) 2014-2017 - Eloi Carbo

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

module("luci.controller.bird6", package.seeall)

function index()
        entry({"admin","network","bird6"},
            alias("admin","network","bird6","status"),
            _("Bird6"), 0)

        entry({"admin", "network", "bird6", "status"},
            cbi("bird6/status"),
            _("Status"), 0).leaf = true

        entry({"admin","network","bird6","log"},
            template("bird6/log"),
            _("Log"), 1).leaf = true

        entry({"admin","network","bird6","overview"},
            cbi("bird6/overview"),
            _("Overview"), 2).leaf = true

        entry({"admin","network","bird6","proto_general"},
            cbi("bird6/gen_proto"),
            _("General protocols"), 3).leaf = true

        entry({"admin","network","bird6","proto_bgp"},
            cbi("bird6/bgp_proto"),
            _("BGP Protocol"), 4).leaf = true

        entry({"admin","network","bird6","filters"},
            cbi("bird6/filters"),
            _("Filters"), 5).leaf = true

        entry({"admin","network","bird6","functions"},
            cbi("bird6/functions"),
            _("Functions"), 6).leaf = true
end
