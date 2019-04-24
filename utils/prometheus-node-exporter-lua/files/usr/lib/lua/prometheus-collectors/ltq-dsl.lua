local function scrape()
  local fd = io.popen("/etc/init.d/dsl_control lucistat")
  local dsl_func = loadstring(fd:read("*a"))
  fd:close()

  if not dsl_func then
    return
  end

  local dsl_stat = dsl_func()

  local dsl_line_attenuation = metric("dsl_line_attenuation_db", "gauge")
  local dsl_signal_attenuation = metric("dsl_signal_attenuation_db", "gauge")
  local dsl_snr = metric("dsl_signal_to_noise_margin_db", "gauge")
  local dsl_aggregated_transmit_power = metric("dsl_aggregated_transmit_power_db", "gauge")
  local dsl_latency = metric("dsl_latency_seconds", "gauge")
  local dsl_datarate = metric("dsl_datarate", "gauge")
  local dsl_max_datarate = metric("dsl_max_datarate", "gauge")
  local dsl_error_seconds_total = metric("dsl_error_seconds_total", "counter")
  local dsl_errors_total = metric("dsl_errors_total", "counter")

  -- dsl hardware/firmware information
  metric("dsl_info", "gauge", {
    atuc_vendor_id = dsl_stat.atuc_vendor_id,
    atuc_system_vendor_id = dsl_stat.atuc_system_vendor_id,
    chipset = dsl_stat.chipset,
    firmware_version = dsl_stat.firmware_version,
    api_version = dsl_stat.api_version,
  }, 1)

  -- dsl line settings information
  metric("dsl_line_info", "gauge", {
    xtse1   = dsl_stat.xtse1,
    xtse2   = dsl_stat.xtse2,
    xtse3   = dsl_stat.xtse3,
    xtse4   = dsl_stat.xtse4,
    xtse5   = dsl_stat.xtse5,
    xtse6   = dsl_stat.xtse6,
    xtse7   = dsl_stat.xtse7,
    xtse8   = dsl_stat.xtse8,
    annex   = dsl_stat.annex_s,
    mode    = dsl_stat.line_mode_s,
    profile = dsl_stat.profile_s,
  }, 1)

  -- dsl up is 1 if the line is up and running
  local dsl_up
  if dsl_stat.line_state == "UP" then
    dsl_up = 1
  else
    dsl_up = 0
  end

  metric("dsl_up", "gauge", {
    detail = dsl_stat.line_state_detail,
  }, dsl_up)

  -- dsl line status data
  metric("dsl_uptime_seconds", "gauge", {}, dsl_stat.line_uptime)

  -- dsl db measurements
  dsl_line_attenuation({direction="down"}, dsl_stat.line_attenuation_down)
  dsl_line_attenuation({direction="up"}, dsl_stat.line_attenuation_up)
  dsl_signal_attenuation({direction="down"}, dsl_stat.signal_attenuation_down)
  dsl_signal_attenuation({direction="up"}, dsl_stat.signal_attenuation_up)
  dsl_snr({direction="down"}, dsl_stat.noise_margin_down)
  dsl_snr({direction="up"}, dsl_stat.noise_margin_up)
  dsl_aggregated_transmit_power({direction="down"}, dsl_stat.actatp_down)
  dsl_aggregated_transmit_power({direction="up"}, dsl_stat.actatp_up)

  -- dsl performance data
  if dsl_stat.latency_down ~= nil then
    dsl_latency({direction="down"}, dsl_stat.latency_down / 1000000)
    dsl_latency({direction="up"}, dsl_stat.latency_up / 1000000)
  end
  dsl_datarate({direction="down"}, dsl_stat.data_rate_down)
  dsl_datarate({direction="up"}, dsl_stat.data_rate_up)
  dsl_max_datarate({direction="down"}, dsl_stat.max_data_rate_down)
  dsl_max_datarate({direction="up"}, dsl_stat.max_data_rate_up)

  -- dsl errors
  dsl_error_seconds_total({err="forward error correction",loc="near"}, dsl_stat.errors_fec_near)
  dsl_error_seconds_total({err="forward error correction",loc="far"}, dsl_stat.errors_fec_far)
  dsl_error_seconds_total({err="errored",loc="near"}, dsl_stat.errors_es_near)
  dsl_error_seconds_total({err="errored",loc="far"}, dsl_stat.errors_es_near)
  dsl_error_seconds_total({err="severely errored",loc="near"}, dsl_stat.errors_ses_near)
  dsl_error_seconds_total({err="severely errored",loc="near"}, dsl_stat.errors_ses_near)
  dsl_error_seconds_total({err="loss of signal",loc="near"}, dsl_stat.errors_loss_near)
  dsl_error_seconds_total({err="loss of signal",loc="far"}, dsl_stat.errors_loss_far)
  dsl_error_seconds_total({err="unavailable",loc="near"}, dsl_stat.errors_uas_near)
  dsl_error_seconds_total({err="unavailable",loc="far"}, dsl_stat.errors_uas_far)
  dsl_errors_total({err="header error code error",loc="near"}, dsl_stat.errors_hec_near)
  dsl_errors_total({err="header error code error",loc="far"}, dsl_stat.errors_hec_far)
  dsl_errors_total({err="non pre-emptive crc error",loc="near"}, dsl_stat.errors_crc_p_near)
  dsl_errors_total({err="non pre-emptive crc error",loc="far"}, dsl_stat.errors_crc_p_far)
  dsl_errors_total({err="pre-emptive crc error",loc="near"}, dsl_stat.errors_crcp_p_near)
  dsl_errors_total({err="pre-emptive crc error",loc="far"}, dsl_stat.errors_crcp_p_far)
end

return { scrape = scrape }
