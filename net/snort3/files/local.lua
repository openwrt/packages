-- This file is no longer used if you are using 'snort-mgr' to create the
-- configuration.  It is left as a sample.
--
-- use ths file to customize any functions defined in /etc/snort/snort.lua

-- switch tap to inline in ips and uncomment the below to run snort in inline mode
--snort = {}
--snort["-Q"] = true

ips = {
  mode = tap,
  -- mode = inline,
  variables = default_variables,
  -- uncomment and change the below to reflect rules or symlinks to rules on your filesystem
  -- include = RULE_PATH .. '/snort.rules',
}

daq = {
  module_dirs = {
    '/usr/lib/daq',
  },
  modules = {
    {
      name = 'afpacket',
      mode = 'inline',
    }
  }
}

alert_syslog = {
  level = 'info',
}

-- To log to a file, uncomment the below and manually create the dir defined in output.logdir
--output.logdir = '/var/log/snort'
--alert_fast = {
--  file = true,
--  packet = false,
--}

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
      verdict = 'log', enable_file_type = true, enable_file_signature = true
    }
  }
}

-- To use openappid with snort, install the openappid package and uncomment the below
--appid = {
--    app_detector_dir = '/usr/lib/openappid',
--    log_stats = true,
--    app_stats_period = 60,
--}
