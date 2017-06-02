#!/usr/bin/lua
-- Metrics web server (0.1)
-- Copyright (c) 2015 Kevin Lyda
-- Copyright (c) 2017 Dan Luedtke <mail@danrl.com>
-- Apache 2.0 License

uci = require("uci")
listen_address = uci.get("metrics", "main", "listen_address")
listen_port = uci.get("metrics", "main", "listen_port")

socket = require("socket")
netsubstat = {"IcmpMsg", "Icmp", "IpExt", "Ip", "TcpExt", "Tcp", "UdpLite", "Udp"}
cpu_mode = {"user", "nice", "system", "idle", "iowait", "irq",
            "softirq", "steal", "guest", "guest_nice"}
netdevsubstat = {"receive_bytes", "receive_packets", "receive_errs",
                 "receive_drop", "receive_fifo", "receive_frame", "receive_compressed",
                 "receive_multicast", "transmit_bytes", "transmit_packets",
                 "transmit_errs", "transmit_drop", "transmit_fifo", "transmit_colls",
                 "transmit_carrier", "transmit_compressed"}

function space_split(s)
  elements = {}
  for element in s:gmatch("%S+") do
    table.insert(elements, element)
  end
  return elements
end

function line_split(s)
  elements = {}
  for element in s:gmatch("[^\n]+") do
    table.insert(elements, element)
  end
  return elements
end

function metrics_header()
  client:send("HTTP/1.1 200 OK\r\nServer: lua-metrics\r\n")
  client:send("Content-Type: text/plain; version=0.0.4\r\n\r\n")
end

function metrics_404()
  client:send("HTTP/1.1 404 Not Found\r\nServer: lua-metrics\r\n")
  client:send("Content-Type: text/plain\r\n\r\nERROR: File Not Found.\r\n")
end

function get_contents(filename)
  local f = io.open(filename, "rb")
  local contents = ""
  if f then
    contents = f:read "*a"
    f:close()
  end

  return contents
end

function print_metric_type(metric, mtype)
  this_metric = metric
  client:send("# TYPE " .. metric .. " " .. mtype .. "\n")
end

function print_metric(labels, value)
  if labels then
    client:send(string.format("%s{%s} %g\n", this_metric, labels, value))
  else
    client:send(string.format("%s %g\n", this_metric, value))
  end
end

function serve(request)
  if not string.match(request, "GET /metrics.*") then
    metrics_404()
    client:close()
    return true
  end

  metrics_header()
  local uname = space_split(io.popen("uname -a"):read("*a"))
  local stat = get_contents("/proc/stat")
  local file_nr = space_split(get_contents("/proc/sys/fs/file-nr"))
  local loadavg = space_split(get_contents("/proc/loadavg"))
  local meminfo = line_split(get_contents(
                    "/proc/meminfo"):gsub("[):]", ""):gsub("[(]", "_"))
  local netstat = get_contents("/proc/net/netstats") .. get_contents("/proc/net/snmp")
  local netdevstat = line_split(get_contents("/proc/net/dev"))
  for i, line in ipairs(netdevstat) do
    netdevstat[i] = string.match(netdevstat[i], "%S.*")
  end

  print_metric_type("node_boot_time", "gauge")
  print_metric(nil, string.match(stat, "btime ([0-9]+)"))
  print_metric_type("node_context_switches", "counter")
  print_metric(nil, string.match(stat, "ctxt ([0-9]+)"))
  print_metric_type("node_cpu", "counter")
  local i = 0
  while string.match(stat, string.format("cpu%d ", i)) do
    cpu = space_split(string.match(stat, string.format("cpu%d ([0-9 ]+)", i)))
    local label = string.format('cpu="cpu%d",mode="%%s"', i)
    for ii, mode in ipairs(cpu_mode) do
      print_metric(string.format(label, mode), cpu[ii] / 100)
    end
    i = i + 1
  end
  print_metric_type("node_filefd_allocated", "gauge")
  print_metric(nil, file_nr[1])
  print_metric_type("node_filefd_maximum", "gauge")
  print_metric(nil, file_nr[3])
  print_metric_type("node_forks", "counter")
  print_metric(nil, string.match(stat, "processes ([0-9]+)"))
  print_metric_type("node_intr", "counter")
  print_metric(nil, string.match(stat, "intr ([0-9]+)"))
  print_metric_type("node_load1", "gauge")
  print_metric(nil, loadavg[1])
  print_metric_type("node_load15", "gauge")
  print_metric(nil, loadavg[3])
  print_metric_type("node_load5", "gauge")
  print_metric(nil, loadavg[2])
  for i, mi in ipairs(meminfo) do
    local mia = space_split(mi)
    print_metric_type("node_memory_" .. mia[1], "gauge")
    if table.getn(mia) == 3 then
      print_metric(nil, mia[2] * 1024)
    else
      print_metric(nil, mia[2])
    end
  end
  for i, nss in ipairs(netsubstat) do
    local substat_s = string.match(netstat, nss .. ": ([A-Z][A-Za-z0-9 ]+)")
    if substat_s then
      local substat = space_split(substat_s)
      local substatv = space_split(string.match(netstat, nss .. ": ([0-9 -]+)"))
      for ii, ss in ipairs(substat) do
        print_metric_type("node_netstat_" .. nss .. "_" .. ss, "gauge")
        print_metric(nil, substatv[ii])
      end
    end
  end
  local nds_table = {}
  local devs = {}
  for i, nds in ipairs(netdevstat) do
    local dev, stat_s = string.match(netdevstat[i], "([^:]+): (.*)")
    if dev then
      nds_table[dev] = space_split(stat_s)
      table.insert(devs, dev)
    end
  end
  for i, ndss in ipairs(netdevsubstat) do
    print_metric_type("node_network_" .. ndss, "gauge")
    for ii, d in ipairs(devs) do
      print_metric('device="' .. d .. '"', nds_table[d][i])
    end
  end

  print_metric_type("node_procs_blocked", "gauge")
  print_metric(nil, string.match(stat, "procs_blocked ([0-9]+)"))
  print_metric_type("node_procs_running", "gauge")
  print_metric(nil, string.match(stat, "procs_running ([0-9]+)"))
  print_metric_type("node_time", "counter")
  print_metric(nil, os.time())
  print_metric_type("node_uname_info", "gauge")
  print_metric(string.format('domainname="(none)",machine="%s",nodename="%s",' ..
                             'release="%s",sysname="%s",version="%s %s %s %s %s %s %s"',
                             uname[11], uname[2], uname[3], uname[1], uname[4], uname[5],
                             uname[6], uname[7], uname[8], uname[9], uname[10]), 1)

  client:close()
  return true
end

-- Main program.
server = assert(socket.bind(listen_address, listen_port))

while 1 do
  client = server:accept()
  client:settimeout(60)
  local request, err = client:receive()

  if not err then
    if not serve(request) then
      break
    end
  end
end
