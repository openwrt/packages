{%
// Copyright (c) 2023 Eric Fahlgren <eric.fahlgren@gmail.com>
// SPDX-License-Identifier: GPL-2.0

// Create some snort-format-specific items.

let home_net = snort.home_net == 'any' ? "'any'" : snort.home_net;
let external_net = snort.external_net;

let line_mode = snort.mode == "ids" ? "tap"     : "inline";
let mod_mode  = snort.mode == "ids" ? "passive" : "inline";

let inputs = null;
let vars   = null;
switch (snort.method) {
case "pcap":
case "afpacket":
	inputs = `{ '${snort.interface}' }`;
	vars   = "{}";
	break;

case "nfq":
	inputs = "{ ";
	for (let i = int(nfq.queue_start); i < int(nfq.queue_start)+int(nfq.queue_count); i++) {
		inputs += `'${i}', `
	}
	inputs += "}";

	vars = `{ 'device=${snort.interface}', 'queue_maxlen=${nfq.queue_maxlen}', 'fanout_type=${nfq.fanout_type}', 'fail_open', }`;
	break;
}
-%}
-- Do not edit, automatically generated.  See /usr/share/snort/templates.

-- These must be defined before processing snort.lua
HOME_NET     = [[ {{ home_net }} ]]
EXTERNAL_NET = [[ {{ external_net }} ]]

include('{{ snort.config_dir }}/snort.lua')

snort  = {
{% if (snort.mode == 'ips'): %}
  ['-Q'] = true,
{% endif %}
  ['--daq'] = '{{ snort.method }}',
--['--daq-dir'] = '/usr/lib/daq/',
{% if (snort.method == 'nfq'): %}
  ['--max-packet-threads'] = {{ nfq.thread_count }},
{% endif %}
}

ips = {
  mode            = '{{ line_mode }}',
  variables       = default_variables,
{% if (snort.action != 'default'): %}
  action_override = '{{ snort.action }}',
{% endif %}
{% if (getenv("_SNORT_WITHOUT_RULES") == "1"): %}
  -- WARNING: THIS IS A TEST-ONLY CONFIGURATION WITHOUT ANY RULES.
{% else %}
  include         = '{{ snort.config_dir }}/' .. RULE_PATH .. '/snort.rules',
{% endif -%}
}

daq = {
  inputs      = {{ inputs }},
  snaplen     = {{ snort.snaplen }},
  module_dirs = { '/usr/lib/daq/', },
  modules     = {
    {
      name      = '{{ snort.method }}',
      mode      = '{{ mod_mode }}',
      variables = {{ vars }},
    }
  }
}

alert_syslog = {
  level = 'info',
}

{% if (int(snort.logging)): %}
-- Note that this is also the location of the PID file, if you use it.
output.logdir = '{{ snort.log_dir }}'

-- alert_full = { file = true, }

--[[
alert_fast = {
-- bool alert_fast.file   = false: output to alert_fast.txt instead of stdout
-- bool alert_fast.packet = false: output packet dump with alert
-- int alert_fast.limit   = 0: set maximum size in MB before rollover (0 is unlimited) { 0:maxSZ }
  file = true,
  packet = false,
}
--]]

alert_json = {
-- bool   alert_json.file      = false: output to alert_json.txt instead of stdout
-- int    alert_json.limit     = 0: set maximum size in MB before rollover (0 is unlimited) { 0:maxSZ }
-- string alert_json.separator = , : separate fields with this character sequence
-- multi  alert_json.fields    = 'timestamp pkt_num proto pkt_gen pkt_len dir src_ap dst_ap'
--                               Rule action: selected fields will be output in given order left to right.
--				{ action | class | b64_data | client_bytes | client_pkts | dir
--				| dst_addr | dst_ap | dst_port | eth_dst | eth_len | eth_src
--				| eth_type | flowstart_time | geneve_vni | gid | icmp_code
--				| icmp_id | icmp_seq | icmp_type | iface | ip_id | ip_len
--				| msg | mpls | pkt_gen | pkt_len | pkt_num | priority
--				| proto | rev | rule | seconds | server_bytes | server_pkts
--				| service | sgt | sid | src_addr | src_ap | src_port | target
--				| tcp_ack | tcp_flags | tcp_len | tcp_seq | tcp_win | timestamp
--				| tos | ttl | udp_len | vlan }

-- This is a minimal set of fields that simply supports 'snort-mgr report'
-- and minimizes log size:
  fields = 'dir src_ap dst_ap msg',

-- This set also supports the report, but closely matches 'alert_fast' contents.
--fields = 'timestamp pkt_num proto pkt_gen pkt_len dir src_ap dst_ap rule action msg',

  file = true,
}

--[[
unified2 = {
  limit = 10, -- int unified2.limit = 0: set maximum size in MB before rollover (0 is unlimited) { 0:maxSZ }
}
--]]

{% endif -%}

normalizer = {
  tcp = {
    ips = true,
  }
}

file_policy = {
  enable_type = true,
  enable_signature = true,
  rules = {
    use = {
      verdict = 'log',
      enable_file_type = true,
      enable_file_signature = true,
    }
  }
}

-- To use openappid with snort, 'opkg install openappid' and enable in config.
{% if (int(snort.openappid)): %}
appid = {
  log_stats = true,
  app_detector_dir = '/usr/lib/openappid',
  app_stats_period = 60,
}
{% endif %}

{%
if (snort.include) {
  // We use the ucode include here, so that the included file is also
  // part of the template and can use values passed in from the config.
  printf("-- The following content from included file '%s'\n", snort.include);
  include(snort.include, { snort, nfq });
}
%}
