-- stat/cpu collector
local function scrape()
  local stat = get_contents("/proc/stat")

  -- system boot time, seconds since epoch
  metric("node_boot_time", "gauge", nil, string.match(stat, "btime ([0-9]+)"))

  -- context switches since boot (all CPUs)
  metric("node_context_switches", "counter", nil, string.match(stat, "ctxt ([0-9]+)"))

  -- cpu times, per CPU, per mode
  local cpu_mode = {"user", "nice", "system", "idle", "iowait", "irq",
                    "softirq", "steal", "guest", "guest_nice"}
  local i = 0
  local cpu_metric = metric("node_cpu", "counter")
  while string.match(stat, string.format("cpu%d ", i)) do
    local cpu = space_split(string.match(stat, string.format("cpu%d ([0-9 ]+)", i)))
    local labels = {cpu = "cpu" .. i}
    for ii, mode in ipairs(cpu_mode) do
      labels['mode'] = mode
      cpu_metric(labels, cpu[ii] / 100)
    end
    i = i + 1
  end

  -- interrupts served
  metric("node_intr", "counter", nil, string.match(stat, "intr ([0-9]+)"))

  -- processes forked
  metric("node_forks", "counter", nil, string.match(stat, "processes ([0-9]+)"))

  -- processes running
  metric("node_procs_running", "gauge", nil, string.match(stat, "procs_running ([0-9]+)"))

  -- processes blocked for I/O
  metric("node_procs_blocked", "gauge", nil, string.match(stat, "procs_blocked ([0-9]+)"))
end

return { scrape = scrape }
