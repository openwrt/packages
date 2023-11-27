{%
// Copyright (c) 2023 Eric Fahlgren <eric.fahlgren@gmail.com>
// SPDX-License-Identifier: GPL-2.0

// Create some snort-format-specific items.

let home_net = snort.home_net == 'any' ? "'any'" : snort.home_net;
let external_net = snort.external_net;

let line_mode = snort.mode == "ids" ? "tap" : "inline";

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
-- The default include '/etc/snort/homenet.lua' must not redefine them.
HOME_NET     = [[ {{ home_net }} ]]
EXTERNAL_NET = '{{ external_net }}'

include('{{ snort.config_dir }}/snort.lua')

snort  = {
{% if (snort.mode == 'ips'): %}
  ['-Q'] = true,
{% endif %}
  ['--daq'] = {{ snort.method }},
--['--daq-dir'] = '/usr/lib/daq/',
{% if (snort.method == 'nfq'): %}
  ['--max-packet-threads'] = {{ nfq.thread_count }},
{% endif %}
}

ips = {
  mode            = {{ line_mode }},
  variables       = default_variables,
  action_override = {{ snort.action }},
  include         = "{{ snort.config_dir }}/" .. RULE_PATH .. '/snort.rules',
}

daq = {
  inputs      = {{ inputs }},
  snaplen     = {{ snort.snaplen }},
  module_dirs = { '/usr/lib/daq/', },
  modules     = {
    {
      name      = '{{ snort.method }}',
      mode      = {{ line_mode }},
      variables = {{ vars }},
    }
  }
}

alert_syslog = {
  level = 'info',
}

{% if (int(snort.logging)): %}
-- Note that this is also the location of the PID file, if you use it.
output.logdir = "{{ snort.log_dir }}"

-- Maybe add snort.log_type, 'fast', 'json' and 'full'?
-- Json would be best for reporting, see 'snort-mgr report' code.
-- alert_full = { file = true, }

alert_fast = {
-- bool alert_fast.file   = false: output to alert_fast.txt instead of stdout
-- bool alert_fast.packet = false: output packet dump with alert
-- int alert_fast.limit   = 0: set maximum size in MB before rollover (0 is unlimited) { 0:maxSZ }
  file = true,
  packet = false,
}
alert_json = {
-- bool   alert_json.file      = false: output to alert_json.txt instead of stdout
-- multi  alert_json.fields    = timestamp pkt_num proto pkt_gen pkt_len dir src_ap dst_ap rule action: selected fields will be output
-- int    alert_json.limit     = 0: set maximum size in MB before rollover (0 is unlimited) { 0:maxSZ }
-- string alert_json.separator = , : separate fields with this character sequence
  file = true,
}

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
