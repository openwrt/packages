Netify Agent
============
Copyright ©2015-2019 eGloo Incorporated ([www.egloo.ca](https://www.egloo.ca))

Network Intelligence - Simplified
---------------------------------

The [Netify Agent](https://www.netify.ai/) is a deep-packet inspection server.  The Agent is built on top of [nDPI](http://www.ntop.org/products/deep-packet-inspection/ndpi/) (formerly OpenDPI) to detect network protocols and applications.  Detections can be saved locally, served over a UNIX or TCP socket, and/or "pushed" (via HTTP POSTs) to a remote third-party server.  Flow metadata, network statistics, and detection classifications are stored using JSON encoding.

Optionally, the Netify Agent can be coupled with a [Netify Cloud](https://www.netify.ai/) subscription for further cloud processing, historical storage, machine-learning analysis, event notifications, device detection/identification, along with the option (on supported platforms) to take an active role in policing/bandwidth-shaping specific network protocols and applications.

Runtime Requirements
--------------------

Ensure that the nfnetlink and nf_conntrack_netlink kernel modules are loaded.

Build Requirements
------------------

Netify requires the following third-party packages:
- libcurl
- libjson-c
- libmnl
- libnetfilter-conntrack
- libpcap
- zlib

Optional:
- libtcmalloc (gperftools)

Download Source
---------------

When cloning the source tree, ensure you use `--recursive` to include all
sub-modules.

Download Packages
-----------------

Currently you can download binary packages for the following OS distributions:
- [ClearOS](https://www.clearos.com/products/purchase/clearos-marketplace-apps#cloud)
- [CentOS](http://software.opensuse.org/download.html?project=home%3Aegloo&package=netifyd)
- [Debian](http://software.opensuse.org/download.html?project=home%3Aegloo&package=netifyd)
- [Fedora](http://software.opensuse.org/download.html?project=home%3Aegloo&package=netifyd)
- [Ubuntu](http://software.opensuse.org/download.html?project=home%3Aegloo&package=netifyd)

Developer Documentation
-----------------------

Further developer documentation can be found [here](https://www.netify.ai/developer/netify-agent).

Configuring/Building From Source
--------------------------------

Read the appropriate documentation in the doc directory, prefixed with: BUILD-*

Generally the process is:
```
# ./autogen.sh
# ./configure
# make
```

License
-------
```
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
```

