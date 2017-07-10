#
# Copyright (C) 2017 Thomas Guyot-Sionnest <tguyot@gmail.com>
# Copyright (C) 2007-2012 OpenWrt.org
# Original port by FreeWRT project.
#
# 2007     Alexander Tsvyashchenko  Adapted FreeWRT port for OpenWRT (Trac ticket 2497)
# 2008     Some Danish guy          Created a port for OpenWRT 7.09
# 20090403 jhalfmoon                Modified and augmented existing packages to work on OpenWRT buildroot (v8.09)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=djbdns
PKG_VERSION:=1.05
PKG_RELEASE:=1

PKG_SOURCE:=${PKG_NAME}-${PKG_VERSION}.tar.gz
PKG_SOURCE_URL:=http://cr.yp.to/djbdns/
PKG_HASH:=3ccd826a02f3cde39be088e1fc6aed9fd57756b8f970de5dc99fcd2d92536b48
PKG_BUILD_DEPENDS:=daemontools ucspi-tcp
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_MAINTAINER:=Thomas Guyot-Sionnest <tguyot@gmail.com>
PKG_LICENSE:=Public Domain

include $(INCLUDE_DIR)/package.mk

define Package/djbdns/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=http://cr.yp.to/djbdns.html
  SUBMENU:=IP Addresses and Names
#  SUBMENU:=djbdns
endef

define Package/djbdns-base
  $(call Package/djbdns/Default)
  TITLE:=djbdns base configuration file
endef

define Package/djbdns-dnscache
  $(call Package/djbdns/Default)
  TITLE:=Recursive and forwarding caching name server
  DEPENDS:= +djbdns-base
endef

define Package/djbdns-tinydns
  $(call Package/djbdns/Default)
  TITLE:=Authoritative name server
  DEPENDS:= +djbdns-base
endef

define Package/djbdns-axfrdns
  $(call Package/djbdns/Default)
  TITLE:=Zone transfer server
  DEPENDS:= +djbdns-base +djbdns-tinydns +ucspi-tcp
endef

define Package/djbdns-rbldns
  $(call Package/djbdns/Default)
  TITLE:=Real-time Block List name server
  DEPENDS:= +djbdns-base
endef

define Package/djbdns-walldns
  $(call Package/djbdns/Default)
  TITLE:=Reverse DNS wall
  DEPENDS:= +djbdns-base
endef

define Package/djbdns-tools
  $(call Package/djbdns/Default)
  TITLE:=Tools for testing and debugging DNS issues
endef

define Package/djdbns/description
	djbdns is a collection of Domain Name System tools.
	It includes software for all the fundamental DNS operations:
	* DNS server: publishing addresses of Internet hosts.
	* DNS cache: finding addresses of Internet hosts.
	* DNS client: talking to a DNS cache.

	Also included is a DNS client C library, several command-line
	DNS client utilities, several DNS debugging tools.
endef

define Package/djbdns-base/description
	The shared config file for the djbdns daemons.
endef

define Package/djbdns-dnscache/description
	dnscache is a DNS cache.
	It accepts recursive DNS queries from local clients such as web
	browsers and mail transfer agents. It collects responses from
	remote DNS servers. It caches the responses to save time later.
endef

define Package/djbdns-tinydns/description
	tinydns is a DNS server.
	It accepts iterative DNS queries from hosts around the Internet
	and responds with locally configured information.
endef

define Package/djbdns-axfrdns/description
	axfrdns is a DNS zone-transfer server.
	It reads a zone-transfer request in DNS-over-TCP format
	from its standard input and responds with locally configured
	information.
endef

define Package/djbdns-rbldns/description
	rbldns is an IP-address-listing DNS server.
	It accepts iterative DNS queries from hosts around the Internet asking
	about various IP addresses. It provides responses showing whether the
	addresses are on a locally configured list, such as RBL or DUL.
endef

define Package/djbdns-walldns/description
	walldns is a reverse DNS wall.
	It accepts iterative DNS queries for in-addr.arpa domains from hosts
	around the Internet and supplies generic responses that avoid
	revealing local host information.
endef

define Package/djbdns-tools/description
	Several command-line DNS client utilities and DNS debugging tools.
endef

define Build/Compile
	TARGET_CC="$(TARGET_CC)" \
	TARGET_CFLAGS="$(TARGET_CFLAGS)" \
	TARGET_LDFLAGS="$(TARGET_LDFLAGS)" \
	TARGET_RANLIB="$(TARGET_CROSS)ranlib" \
	$(MAKE) -C $(PKG_BUILD_DIR)
endef

define Package/djbdns-base/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/djbdns.conf $(1)/etc/config/djbdns
endef

define Package/djbdns-base/conffiles
/etc/config/djbdns
endef

define Package/djbdns-dnscache/install
	$(INSTALL_DIR) $(1)/usr/bin
	(cd $(PKG_BUILD_DIR); \
	$(INSTALL_BIN) dnscache pickdns pickdns-data $(1)/usr/bin)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/dnscache.init $(1)/etc/init.d/dnscache
	$(CP) -r ./files/dnscache $(1)/etc/
	$(CP) $(PKG_BUILD_DIR)/dnsroots.global $(1)/etc/dnscache/
	$(INSTALL_DIR) $(1)/etc/dnscache/ip
	$(INSTALL_DIR) $(1)/etc/dnscache/servers
	$(CP) $(PKG_BUILD_DIR)/dnsroots.global $(1)/etc/dnscache/servers/@
endef

define Package/djbdns-tinydns/install
	$(INSTALL_DIR) $(1)/usr/bin
	(cd $(PKG_BUILD_DIR); \
	$(INSTALL_BIN) tinydns tinydns-data tinydns-edit tinydns-get $(1)/usr/bin)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tinydns.init $(1)/etc/init.d/tinydns
	$(CP) -r ./files/tinydns $(1)/etc/
endef

define Package/djbdns-axfrdns/install
	$(INSTALL_DIR) $(1)/usr/bin
	(cd $(PKG_BUILD_DIR); \
	$(INSTALL_BIN) axfrdns axfr-get $(1)/usr/bin)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/axfrdns.init $(1)/etc/init.d/axfrdns
	$(CP) -r ./files/axfrdns $(1)/etc/
endef

define Package/djbdns-rbldns/install
	$(INSTALL_DIR) $(1)/usr/bin
	(cd $(PKG_BUILD_DIR); \
	$(INSTALL_BIN) rbldns rbldns-data $(1)/usr/bin)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/rbldns.init $(1)/etc/init.d/rbldns
	$(CP) -r ./files/rbldns $(1)/etc/
endef

define Package/djbdns-walldns/install
	$(INSTALL_DIR) $(1)/usr/bin
	(cd $(PKG_BUILD_DIR); \
	$(INSTALL_BIN) walldns $(1)/usr/bin)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/walldns.init $(1)/etc/init.d/walldns
endef

define Package/djbdns-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	(cd $(PKG_BUILD_DIR); \
	$(INSTALL_BIN) dnsfilter dnsip dnsipq dnsmx dnsname dnsnamex dnsq \
                       dnsqr dnstrace dnstracesort dnstxt random-ip \
	$(1)/usr/bin)
	$(INSTALL_BIN) ./files/dnsroots-update $(1)/usr/bin/
	$(INSTALL_BIN) ./files/dnsqrx $(1)/usr/bin/
endef

$(eval $(call BuildPackage,djbdns-base))
$(eval $(call BuildPackage,djbdns-tinydns))
$(eval $(call BuildPackage,djbdns-dnscache))
$(eval $(call BuildPackage,djbdns-axfrdns))
$(eval $(call BuildPackage,djbdns-rbldns))
$(eval $(call BuildPackage,djbdns-walldns))
$(eval $(call BuildPackage,djbdns-tools))
