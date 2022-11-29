-- use ths file to customize any functions defined in /etc/snort/snort.lua

-- switch tap to inline in ips and uncomment the below to run snort in inline mode
--snort = {}
--snort["-Q"] = ''

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
