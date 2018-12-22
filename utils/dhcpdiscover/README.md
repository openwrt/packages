* Program: dhcpdiscover
  
  This program checks the existence and more details of a DHCP server

* About the code structure

  The Makefile found in the directory of this README is for OpenWRT. It can be imported as a package. Inside the src/ directory the C code of dhcpdiscover can be found. If you want to compile it for your computer execute: cd src && make

* Licence information

  Code under GPLv3
  
  Copyright (c) 2001-2004 Ethan Galstad (nagios@nagios.org), 2013 OpenWRT.org 

* Contributors

  Mike Gore 25 Aug 2005: Modified for standalone operation   
  Pau Escrich Jun 2013: Added -b option and ported to OpenWRT 


___________________________________________________________

 
```
Usage: dhcpdiscover [-s serverip] [-r requestedip] [-m clientmac ] [-b bannedip] [-t timeout] [-i interface]
                  [-v] -s, --serverip=IPADDRESS
   IP address of DHCP server that we must hear from
 -r, --requestedip=IPADDRESS
   IP address that should be offered by at least one DHCP server
 -m, --mac=MACADDRESS
   Client MAC address to use for sending packets
 -b, --bannedip=IPADDRESS
   Server IP address to ignore
 -t, --timeout=INTEGER
   Seconds to wait for DHCPOFFER before timeout occurs
 -i, --interface=STRING
   Interface to to use for listening (i.e. eth0)
 -v, --verbose
   Print extra information (command-line use only)
 -p, --prometheus
   Print extra information in prometheus format
 -h, --help
   Print detailed help screen
 -V, --version
   Print version information

Example: sudo ./dhcpdiscover -i eth0 -b 192.168.1.1
```
