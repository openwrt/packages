// This example configuration file is a good starting point, but you're
// strongly encouraged to take a look at the full documentation: https://reaction.ppom.me

// Based on: https://reaction.ppom.me/actions/nftables.html
// NOTE: fail2ban uses hook priority -1 by default, will do the same

local banFor(time) = {
  ban: {
    cmd: ['nft46', 'add element inet reaction ipvXbans { <ip> }'],
  },
  unban: {
    cmd: ['nft46', 'delete element inet reaction ipvXbans { <ip> }'],
    after: time,
  },
};

{
  patterns: {
    ip: {
      // reaction regex syntax is defined here: https://github.com/google/re2/wiki/Syntax
      // jsonnet's @'string' is for verbatim strings
      // simple version:
      // regex: @'(?:(?:[0-9]{1,3}\.){3}[0-9]{1,3})|(?:[0-9a-fA-F:]{2,90})',
      regex: @'(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(?:\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}|(?:(?:[0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|(?:[0-9a-fA-F]{1,4}:){1,7}:|(?:[0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|(?:[0-9a-fA-F]{1,4}:){1,5}(?::[0-9a-fA-F]{1,4}){1,2}|(?:[0-9a-fA-F]{1,4}:){1,4}(?::[0-9a-fA-F]{1,4}){1,3}|(?:[0-9a-fA-F]{1,4}:){1,3}(?::[0-9a-fA-F]{1,4}){1,4}|(?:[0-9a-fA-F]{1,4}:){1,2}(?::[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:(?:(?::[0-9a-fA-F]{1,4}){1,6})|:(?:(?::[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(?::[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(?:ffff(?::0{1,4}){0,1}:){0,1}(?:(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9])|(?:[0-9a-fA-F]{1,4}:){1,4}:(?:(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9]))',
      ignore: ['127.0.0.1', '::1'],
      // Patterns can be ignored based on regexes, it will try to match the whole string detected by the pattern
      // ignoreregex: [@'10\.0\.[0-9]{1,3}\.[0-9]{1,3}'],
      // ignoreregex: [@'192\.168\.[0-9]{1,3}\.[0-9]{1,3}'],
    },
  },

  start: [
    ['nft', |||
    table inet reaction {
      set ipv4bans {
        type ipv4_addr
        flags interval
        auto-merge
      }
      set ipv6bans {
        type ipv6_addr
        flags interval
        auto-merge
      }
      chain input {
        type filter hook input priority -1
        policy accept
        ip saddr @ipv4bans drop
        ip6 saddr @ipv6bans drop
      }
    }
||| ],
  ],
  stop: [
    ['nft', 'delete table inet reaction'],
  ],

  streams: {
    // Ban hosts failing to connect via ssh
    ssh: {
      // Read all messages to authpriv facility (10)
      cmd: ['logread', '-f', '-z', '10'],
      filters: {
        failedlogin: {
          regex: [
            // https://reaction.ppom.me/filters/ssh.html
            // Auth fail
            @'authentication failure;.*rhost=<ip>',
            // Client disconnects during authentication
            @'Connection (reset|closed) by (authenticating|invalid) user .* <ip> port',
            @'Connection (reset|closed) by <ip> port',
            // More specific auth fail
            @'Failed password for .* from <ip>',
            // Other auth failures
            @'banner exchange: Connection from <ip> port [0-9]*: invalid format',
            @'Invalid user .* from <ip>',

            // Dropbear
            @'Login attempt for nonexistent user from <ip>',
            @'Exit before auth from \<<ip>:[0-9]*\>:.*Error reading:',
          ],
          retry: 3,
          retryperiod: '6h',
          actions: banFor('48h'),
        },
      },
    },
  },
}
