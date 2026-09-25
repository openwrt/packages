local function get_devices()
    local handle = io.popen("ubnt-manager -l")
    local result = handle:read("*a")
    handle:close()

    local devices = {}
    for device in result:gmatch("%S+") do table.insert(devices, device) end
    return devices
end

local function get_metric_airos6(device_data, label, label_full)
    -- host
    metric("ubnt_uptime", "counter", label_full, device_data['host']['uptime'])
    metric("ubnt_totalram", "gauge", label, device_data['host']['totalram'])
    metric("ubnt_freeram", "gauge", label, device_data['host']['freeram'])
    metric("ubnt_cpuload", "gauge", label, device_data['host']['cpuload'])
    metric("ubnt_cpubusy", "gauge", label, device_data['host']['cpubusy'])
    metric("ubnt_cputotal", "gauge", label, device_data['host']['cputotal'])

    -- wireless
    metric("ubnt_channel", "gauge", label, device_data['wireless']['channel'])
    local freqstring = {}
    for freq in device_data['wireless']['frequency']:gmatch("%S+") do
        table.insert(freqstring, freq)
    end
    if freqstring[1] then
        metric("ubnt_frequency", "gauge", label, tonumber(freqstring[1]))
    end

    metric("ubnt_dfs", "gauge", label, tonumber(device_data['wireless']['dfs']))
    metric("ubnt_signal", "gauge", label, device_data['wireless']['signal'])
    metric("ubnt_rssi", "gauge", label, device_data['wireless']['rssi'])
    metric("ubnt_noisef", "gauge", label, device_data['wireless']['noisef'])
    metric("ubnt_txpower", "gauge", label, device_data['wireless']['txpower'])
    metric("ubnt_distance", "gauge", label, device_data['wireless']['distance'])
    metric("ubnt_txrate", "gauge", label,
           tonumber(device_data['wireless']['txrate']))
    metric("ubnt_rxrate", "gauge", label,
           tonumber(device_data['wireless']['rxrate']))
    metric("ubnt_count", "gauge", label, device_data['wireless']['count'])
end

local function get_metric_airos8(device_data, label, label_full)
    -- host
    metric("ubnt_uptime", "counter", label_full, device_data['host']['uptime'])
    metric("ubnt_loadavg", "gauge", label, device_data['host']['loadavg'])
    metric("ubnt_totalram", "gauge", label, device_data['host']['totalram'])
    metric("ubnt_freeram", "gauge", label, device_data['host']['freeram'])
    metric("ubnt_temperature", "gauge", label,
           device_data['host']['temperature'])
    metric("ubnt_cpuload", "gauge", label, device_data['host']['cpuload'])
    metric("ubnt_timestamp", "counter", label, device_data['host']['timestamp'])

    -- wireless
    metric("ubnt_band", "gauge", label, device_data['wireless']['band'])
    metric("ubnt_frequency", "gauge", label,
           device_data['wireless']['frequency'])
    metric("ubnt_center1_freq", "gauge", label,
           device_data['wireless']['center1_freq'])
    metric("ubnt_dfs", "gauge", label, device_data['wireless']['dfs'])
    metric("ubnt_distance", "gauge", label, device_data['wireless']['distance'])
    metric("ubnt_noisef", "gauge", label, device_data['wireless']['noisef'])
    metric("ubnt_txpower", "gauge", label, device_data['wireless']['txpower'])
    metric("ubnt_aprepeater", "gauge", label,
           device_data['wireless']['aprepeater'])
    metric("ubnt_rstatus", "gauge", label, device_data['wireless']['rstatus'])
    metric("ubnt_chanbw", "gauge", label, device_data['wireless']['chanbw'])
    metric("ubnt_rx_chainmask", "gauge", label,
           device_data['wireless']['rx_chainmask'])
    metric("ubnt_tx_chainmask", "gauge", label,
           device_data['wireless']['tx_chainmask'])
    metric("ubnt_cac_state", "gauge", label,
           device_data['wireless']['cac_state'])
    metric("ubnt_cac_timeout", "gauge", label,
           device_data['wireless']['cac_timeout'])
    metric("ubnt_rx_idx", "gauge", label, device_data['wireless']['rx_idx'])
    metric("ubnt_rx_nss", "gauge", label, device_data['wireless']['rx_nss'])
    metric("ubnt_tx_idx", "gauge", label, device_data['wireless']['tx_idx'])
    metric("ubnt_tx_nss", "gauge", label, device_data['wireless']['tx_nss'])
    metric("ubnt_count", "gauge", label, device_data['wireless']['count'])

    -- wireless throughput
    metric("ubnt_throughput_tx", "gauge", label,
           device_data['wireless']['throughput']['tx'])
    metric("ubnt_throughput_rx", "gauge", label,
           device_data['wireless']['throughput']['rx'])

    -- wireless polling
    metric("ubnt_polling_cb_capacity", "gauge", label,
           device_data['wireless']['polling']['cb_capacity'])
    metric("ubnt_polling_dl_capacity", "gauge", label,
           device_data['wireless']['polling']['dl_capacity'])
    metric("ubnt_polling_ul_capacity", "gauge", label,
           device_data['wireless']['polling']['ul_capacity'])
    metric("ubnt_use", "gauge", label, device_data['wireless']['polling']['use'])
    metric("ubnt_tx_use", "gauge", label,
           device_data['wireless']['polling']['tx_use'])
    metric("ubnt_rx_use", "gauge", label,
           device_data['wireless']['polling']['rx_use'])
    metric("ubnt_atpc_status", "gauge", label,
           device_data['wireless']['polling']['atpc_status'])
    metric("ubnt_atpc_status", "gauge", label,
           device_data['wireless']['polling']['atpc_status'])
end

local function get_metric(device)
    local json = require('cjson')
    local handle = io.popen("ubnt-manager -j -t " .. device)
    local result = handle:read("*a")
    handle:close()
    local device_data = json.decode(result)

    if not device_data['host'] then return end
    if not device_data['wireless'] then return end

    local hostname = device_data['host']['hostname']
    local devmodel = device_data['host']['devmodel']
    local fwversion = device_data['host']['fwversion']
    local essid = device_data['wireless']['essid']

    local label_short = {
       device = device
    }

    local label_full = {
       device = device,
       hostname = hostname,
       devmodel = devmodel,
       fwversion = fwversion,
       essid = essid
   }

    -- v6. vs v8.
    if fwversion:find("v8.", 1, true) then
        get_metric_airos8(device_data, label_short, label_full)
    elseif fwversion:find("v6.", 1, true) then
        get_metric_airos6(device_data, label_short, label_full)
    end
end

local function scrape()
    for _, device in ipairs(get_devices()) do get_metric(device) end
end

return {scrape = scrape}
