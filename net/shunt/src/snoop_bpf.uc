// shunt - BPF program for the snoop socket
//
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 Dirk Brenken (dev@brenken.org)
//
// GENERATED - do not edit.
//
// Expression: udp src port 53 or (vlan and udp src port 53)
// Link type:  EN10MB (br-lan)
// Instructions: 52
// tcpdump version 4.99.6
// libpcap version 1.10.6 (64-bit time_t, with TPACKET_V3)
// 64-bit build, 64-bit time_t
//
// Take it whole. The vlan primitive prefixes `ld #0; st M[0];
// st M[1]` and the later branches read those scratch slots, so
// dropping the preamble or splicing the two halves breaks the
// tagged path silently. Without `vlan` the program would start
// at `ldh [12]` and be 16 instructions instead of 52.
//
// Return style, not export style, and that is load bearing:
// snoop.uc loads this with require() at open() time so the
// module itself stays loadable without the constant, and
// require() only accepts return style - export syntax fails to
// compile outside an import.

return {
	BPF: [
		[ 0, 0, 0, 0 ],
		[ 2, 0, 0, 0 ],
		[ 2, 0, 0, 1 ],
		[ 40, 0, 0, 12 ],
		[ 21, 0, 4, 34525 ],
		[ 48, 0, 0, 20 ],
		[ 21, 0, 10, 17 ],
		[ 40, 0, 0, 54 ],
		[ 21, 41, 8, 53 ],
		[ 21, 0, 7, 2048 ],
		[ 48, 0, 0, 23 ],
		[ 21, 0, 5, 17 ],
		[ 40, 0, 0, 20 ],
		[ 69, 3, 0, 8191 ],
		[ 177, 0, 0, 14 ],
		[ 72, 0, 0, 14 ],
		[ 21, 33, 0, 53 ],
		[ 48, 0, 0, 4294963248 ],
		[ 21, 7, 0, 1 ],
		[ 0, 0, 0, 4 ],
		[ 2, 0, 0, 0 ],
		[ 2, 0, 0, 1 ],
		[ 40, 0, 0, 12 ],
		[ 21, 2, 0, 33024 ],
		[ 21, 1, 0, 34984 ],
		[ 21, 0, 25, 37120 ],
		[ 97, 0, 0, 1 ],
		[ 72, 0, 0, 12 ],
		[ 21, 0, 6, 34525 ],
		[ 97, 0, 0, 0 ],
		[ 80, 0, 0, 20 ],
		[ 21, 0, 19, 17 ],
		[ 97, 0, 0, 0 ],
		[ 72, 0, 0, 54 ],
		[ 21, 15, 16, 53 ],
		[ 21, 0, 15, 2048 ],
		[ 97, 0, 0, 0 ],
		[ 80, 0, 0, 23 ],
		[ 21, 0, 12, 17 ],
		[ 97, 0, 0, 0 ],
		[ 72, 0, 0, 20 ],
		[ 69, 9, 0, 8191 ],
		[ 97, 0, 0, 0 ],
		[ 80, 0, 0, 14 ],
		[ 84, 0, 0, 15 ],
		[ 100, 0, 0, 2 ],
		[ 12, 0, 0, 0 ],
		[ 7, 0, 0, 0 ],
		[ 72, 0, 0, 14 ],
		[ 21, 0, 1, 53 ],
		[ 6, 0, 0, 262144 ],
		[ 6, 0, 0, 0 ],
	]
};
