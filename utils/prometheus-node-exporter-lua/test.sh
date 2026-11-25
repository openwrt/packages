#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
prometheus-node-exporter-lua-openwrt)
	# call ubus outside scape, so skip the check
	exit 0
	;;

prometheus-node-exporter-lua-hwmon)
	# run the installed collector against a fake sysfs
	lua - <<'LUA' || exit 1
local function iter(list)
	local i = 0
	return function()
		i = i + 1
		return list[i]
	end
end

local function scrape(sys)
	local paths = {}
	for hwmon in pairs(sys) do
		paths[#paths + 1] = "/sys/class/hwmon/" .. hwmon
	end
	table.sort(paths)

	package.loaded["nixio.fs"] = {
		glob = function(pattern)
			if pattern == "/sys/class/hwmon/hwmon*" then
				return iter(paths)
			end
			local dir, hwmon = pattern:match("^(.*/(hwmon%d+))/temp")
			if dir then
				return iter({ dir .. "/temp1_input" })
			end
			dir, hwmon = pattern:match("^(.*/(hwmon%d+))/pwm")
			if dir and sys[hwmon].pwm then
				return iter({ dir .. "/pwm1" })
			end
			return iter({})
		end,
		basename = function(path)
			return path:match("([^/]+)$")
		end,
		dirname = function(path)
			return path:match("(.+)/[^/]+$")
		end,
		realpath = function(path)
			local device = sys[path:match("(hwmon%d+)/device$")].device
			if device then
				return device
			end
			return nil, 2, "No such file or directory"
		end,
	}

	local series = {}
	_G.metric = function(name)
		return function(labels, value)
			local key = string.format("%s{chip=%s,sensor=%s,chip_name=%s}",
				name, labels.chip, tostring(labels.sensor), tostring(labels.chip_name))
			assert(not series[key], "duplicate series: " .. key)
			series[key] = string.format("%g", value)
		end
	end
	_G.get_contents = function(path)
		local hwmon, file = path:match("(hwmon%d+)/(.*)$")
		if file == "name" then
			return sys[hwmon].name .. "\n"
		elseif file == "temp1_input" then
			return sys[hwmon].temp .. "\n"
		elseif file == "pwm1" then
			return sys[hwmon].pwm .. "\n"
		end
		return ""
	end

	assert(loadfile("/usr/lib/lua/prometheus-collectors/hwmon.lua"))().scrape()
	return series
end

local function check(series, key, value)
	assert(series[key] == value, key .. " is " .. tostring(series[key]))
end

-- distinct names on one device: the name makes chip unique
local phy = "/sys/devices/pci/ieee80211/phy0"
local series = scrape({
	hwmon0 = { name = "mt7996_phy0.0", device = phy, temp = 51000, pwm = 10 },
	hwmon1 = { name = "mt7996_phy0.1", device = phy, temp = 52000, pwm = 20 },
})
check(series, "node_hwmon_chip_names{chip=ieee80211_phy0_mt7996_phy0_0,sensor=nil,chip_name=mt7996_phy0.0}", "1")
check(series, "node_hwmon_temp_celsius{chip=ieee80211_phy0_mt7996_phy0_1,sensor=temp1,chip_name=nil}", "52")
check(series, "node_hwmon_pwm{chip=ieee80211_phy0_mt7996_phy0_1,sensor=pwm1,chip_name=nil}", "20")

-- same name on one device: fall back to hwmonX
series = scrape({
	hwmon0 = { name = "wmi", device = "/sys/devices/platform/board", temp = 40000 },
	hwmon1 = { name = "wmi", device = "/sys/devices/platform/board", temp = 41000 },
})
check(series, "node_hwmon_temp_celsius{chip=platform_board_hwmon1,sensor=temp1,chip_name=nil}", "41")

-- same name without device: fall back to hwmonX
series = scrape({
	hwmon0 = { name = "coretemp", temp = 40000 },
	hwmon1 = { name = "coretemp", temp = 41000 },
})
check(series, "node_hwmon_temp_celsius{chip=coretemp_hwmon0,sensor=temp1,chip_name=nil}", "40")

-- no collision: chip stays as is
series = scrape({
	hwmon0 = { name = "cpu_thermal", device = "/sys/devices/virtual/thermal/thermal_zone0", temp = 45000 },
	hwmon1 = { name = "mdio_bus:01", device = "/sys/bus/mdio-bus/mdio-bus:01", temp = 52000 },
})
check(series, "node_hwmon_chip_names{chip=thermal_thermal_zone0,sensor=nil,chip_name=cpu_thermal}", "1")
check(series, "node_hwmon_temp_celsius{chip=mdio-bus_mdio-bus:01,sensor=temp1,chip_name=nil}", "52")
LUA
	;;
esac

prometheus-node-exporter-lua | grep node_scrape_collector_success
