# Netify Agent
Copyright ©2015-2020 eGloo Incorporated ([www.egloo.ca](https://www.egloo.ca))

## Network Intelligence - Simplified
The [Netify Agent](https://www.netify.ai/) is a deep-packet inspection server.  The Agent is built on top of [nDPI](http://www.ntop.org/products/deep-packet-inspection/ndpi/) (formerly OpenDPI) to detect network protocols and applications.  Detections can be saved locally, served over a UNIX or TCP socket, and/or "pushed" (via HTTP POSTs) to a remote third-party server.  Flow metadata, network statistics, and detection classifications are stored using JSON encoding.

Optionally, the Netify Agent can be coupled with a [Netify Cloud](https://www.netify.ai/) subscription for further cloud processing, historical storage, machine-learning analysis, event notifications, device detection/identification, along with the option (on supported platforms) to take an active role in policing/bandwidth-shaping specific network protocols and applications.

## Download Packages
Supported platforms with installation instructions can be found [here](https://www.netify.ai/get-netify).

Alternatively, binary packages are available for the following OS distributions (manual install):
- [CentOS](http://download.netify.ai/netify/centos/)
- [ClearOS](http://download.netify.ai/netify/clearos/)
- [Debian](http://download.netify.ai/netify/debian/)
- [FreeBSD](http://download.netify.ai/netify/freebsd/)
- [NethServer](http://download.netify.ai/netify/nethserver/)
- [OpenWrt/LEDE](https://downloads.openwrt.org/snapshots/packages/)
- [pfSense](http://download.netify.ai/netify/pfsense/)
- [Raspbian](https://software.opensuse.org//download.html?project=home%3Aegloo&package=netifyd)
- [RHEL](http://download.netify.ai/netify/rhel/)
- [Ubuntu](http://download.netify.ai/netify/ubuntu/)

### Runtime Requirements
- [Linux] Ensure that the nfnetlink and nf_conntrack_netlink kernel modules are loaded if NAT detection is enabled.

## Download Source
When cloning the source tree, ensure you use `--recursive` to include all
sub-modules.

### Build Requirements
Netify requires the following third-party packages:
- libcurl
- libpcap
- zlib
- [Linux] libmnl
- [Linux] libnetfilter-conntrack

Optional:
- google-perftools/gperftools/libtcmalloc (will use bundled version when not available)

### Configuring/Building From Source
Read the appropriate documentation in the doc directory, prefixed with: `BUILD-*`

Generally the process is:
```sh
./autogen.sh
./configure
make
```

## Online Documentation
Further user and developer documentation can be found [here](https://www.netify.ai/resources).

## License
This software is licenced under the [GPLv3](https://www.gnu.org/licenses/gpl-3.0.txt):
>>>
Copyright (C) 2015-2020 eGloo Incorporated

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
>>>
