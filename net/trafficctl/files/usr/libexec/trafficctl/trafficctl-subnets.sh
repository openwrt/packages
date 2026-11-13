#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# List the subnets this router monitors, as CIDRs the dashboard can offer as
# rate-limit targets.
#
# Output: JSON array
#   [{"cidr":"192.168.20.0/24","device":"br-guest","kind":"lan"},
#    {"cidr":"10.0.5.0/24","device":"br-lan","kind":"routed"}]
#
# kind is "lan" for a directly connected subnet and "routed" for one reached
# via a next-hop on a LAN device (or listed in trafficctl.main.extra_subnets).
#
# This list is exactly the set a limit can be ENFORCED on: the netdev hooks
# that police traffic are attached to the devices these subnets resolve to, so
# a subnet missing from here (a masquerading non-lan zone, for instance) would
# take a rule that never matches a packet. The dashboard warns off such a
# target instead of pretending it applied.

. /usr/libexec/trafficctl/trafficctl-fw.sh

tctl_monitored_subnets | awk '
# Octets are derived with arithmetic and printed individually: each is below
# 256, while the packed address is up to 2^32-1 and busybox awk formats "%d"
# through a 32-bit int.
function ip2s(v,   o1, o2, o3, o4, rem) {
    o1 = int(v / 16777216); rem = v - o1 * 16777216
    o2 = int(rem / 65536);  rem = rem - o2 * 65536
    o3 = int(rem / 256)
    o4 = rem - o3 * 256
    return sprintf("%d.%d.%d.%d", o1, o2, o3, o4)
}
{
    base = $2 + 0
    block = $3 + 0
    if (block < 1) next
    # block is a power of two (1 << (32 - mask)); count it back down rather
    # than calling log(), which awk only has in floating point.
    mask = 32
    b = block
    while (b > 1) { b = b / 2; mask-- }
    # router_int is 0 for a subnet that has no local address inside it, which
    # is what tells a routed subnet from a connected one.
    # Written long-hand: the bashism linter reads the whole file, and
    # `name = (...)` at the start of a line looks like a shell array to it.
    kind = "lan"
    if ($4 + 0 == 0) { kind = "routed" }
    if (n++) printf ","
    else printf "["
    printf "{\"cidr\":\"%s/%d\",\"device\":\"%s\",\"kind\":\"%s\"}", ip2s(base), mask, $1, kind
}
END { if (!n) printf "["; printf "]\n" }
'
