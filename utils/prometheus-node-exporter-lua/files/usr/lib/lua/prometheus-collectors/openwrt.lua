local labels = {
    id = "",
    release = "",
    revision = "",
    model = string.sub(get_contents("/tmp/sysinfo/model"), 1, -2),
    board_name = string.sub(get_contents("/tmp/sysinfo/board_name"), 1, -2)
}

for k, v in string.gmatch(get_contents("/etc/openwrt_release"), "(DISTRIB_%w+)='(%w+)'\n") do
    if k == "DISTRIB_ID" then
        labels["id"] = v
    elseif k == "DISTRIB_RELEASE" then
        labels["release"] = v
    elseif k == "DISTRIB_REVISION" then
        labels["revision"] = v
    end
end

local function scrape()
    metric("node_openwrt_info", "gauge", labels, 1)
end

return { scrape = scrape }

