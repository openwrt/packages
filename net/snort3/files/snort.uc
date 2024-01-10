{%
// Copyright (c) 2023-2024 Eric Fahlgren <eric.fahlgren@gmail.com>
// SPDX-License-Identifier: GPL-2.0

import { lsdir } from 'fs';

// Create some snort-format-specific items.

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
HOME_NET     = [[ {{ snort.home_net }} ]]
EXTERNAL_NET = [[ {{ snort.external_net }} ]]

include('{{ snort.config_dir }}/snort.lua')

snort  = {
{% if (snort.mode == 'ips'): %}
  ['-Q'] = true,
{% endif %}
  ['--daq'] = '{{ snort.method }}',
{% if (snort.method == 'nfq'): %}
  ['--max-packet-threads'] = {{ nfq.thread_count }},
{% endif %}
}

ips = {
  -- View all options with "snort --help-module ips"
  mode            = '{{ line_mode }}',
  variables       = default_variables,
--enable_builtin_rules=true,
{% if (snort.action != 'default'): %}
  action_override = '{{ snort.action }}',
{% endif %}
{% if (getenv("_SNORT_WITHOUT_RULES") == "1"): %}
  -- WARNING: THIS IS A TEST-ONLY CONFIGURATION WITHOUT ANY RULES.
{% else %}
  rules = [[
{%
    let rules_dir = snort.config_dir + '/rules';
    for (let rule in lsdir(rules_dir)) {
      if (wildcard(rule, '*includes.rules', true)) continue;
      if (wildcard(rule, '*.rules', true)) {
        printf(`    include ${rules_dir}/${rule}\n`);
      }
    }
%}
  ]],
{% endif -%}
}

daq = {
  -- View all options with "snort --help-module daq"
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

-- alert_syslog = { level = 'info', }  -- Generate output to syslog.
alert_syslog = nil -- Disable output to syslog

{% if (int(snort.logging)): %}
-- Note that this is also the location of the PID file, if you use it.
output = {
  -- View all options with "snort --help-module output"
  logdir    = '{{ snort.log_dir }}',

  show_year = true,  -- Include year in timestamps.
  -- See also 'process.utc = true' if you wish to record timestamps
  -- in UTC.
}

--[[
alert_full = {
  -- View all options with "snort --help-config alert_full"
  file = true,
}
--]]

--[[
alert_fast = {
  -- View all options with "snort --help-config alert_fast"
  file = true,
  packet = false,
}
--]]

alert_json = {
  -- View all options with "snort --help-config alert_json"
  file = true,

  -- This is a minimal set of fields that simply supports 'snort-mgr report'
  -- and minimizes log size, but loses a lot of information:
--fields = 'timestamp dir src_addr src_port dst_addr dst_port gid sid msg',

  -- This is our preferred smallish set, which also supports the report, but
  -- more closely matches 'alert_fast' contents.
  fields = [[
    timestamp
    pkt_num pkt_gen pkt_len
    proto
    dir
    src_addr src_port
    dst_addr dst_port
    gid sid rev
    action
    msg
  ]],
}

{% endif -%}

normalizer = {
  tcp = {
    ips = true,
  }
}

file_policy = {
  enable_type      = true,
  enable_signature = true,
  rules = {
    use = {
      verdict               = 'log',
      enable_file_type      = true,
      enable_file_signature = true,
    }
  }
}

-- To use openappid with snort, 'opkg install openappid' and enable in config.
{% if (int(snort.openappid)): %}
appid = {
  -- View all options with "snort --help-module appid"
  log_stats        = true,
  app_detector_dir = '/usr/lib/openappid',
  app_stats_period = 60,
}
{% endif %}

{%
if (snort.include) {
  // We use the ucode include here, so that the included file is also
  // part of the template and can use values passed in from the config.
  printf(rpad(`-- Include from '${snort.include}'`, ">", 80) + "\n");
  include(snort.include, { snort, nfq });
  printf(rpad("-- End of included file.", "<", 80) + "\n");
}
%}
