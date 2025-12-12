#
# Copyright (C) 2022 Alexander E. Patrakov
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Special thanks to the Debian and Fedora projects for their hping3
# packaging, elements of which (patches, list of dependencies, etc.) are
# reused here.

include $(TOPDIR)/rules.mk

PKG_NAME:=hping3
PKG_SOURCE_DATE:=2014-12-26
PKG_SOURCE_VERSION:=3547c7691742c6eaa31f8402e0ccbb81387c1b99
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/antirez/hping
PKG_MIRROR_HASH:=ededbdf09ae0b9d0758514ea625412296125010ce87285bc3a8afb52155a5e67

PKG_MAINTAINER:=Alexander E. Patrakov <patrakov@gmail.com>
PKG_LICENSE:=GPL-2.0-only

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/hping3
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Active Network Smashing Tool
	URL:=https://github.com/antirez/hping
	DEPENDS:= +libpcap
endef

define Package/hping3/description
	hping3 is a network tool able to send custom ICMP/UDP/TCP packets
	and to display target replies like ping does with ICMP replies. It
	handles fragmentation and arbitrary packet body and size, and can
	be used to transfer files under supported protocols. Using hping3,
	you can test firewall rules, perform (spoofed) port scanning, test
	network performance using different protocols, do path MTU
	discovery, perform traceroute-like actions under different
	protocols, fingerprint remote operating systems, audit TCP/IP
	stacks, etc. Tcl support is not included.
endef

define Package/hping3/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hping3 $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,hping3))
