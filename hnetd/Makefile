#
# Copyright (C) 2012-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=hnetd
PKG_SOURCE_VERSION:=a7fb081a9b98a150f2fda913886c6c0ef0725048
PKG_VERSION:=2014-05-04-$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://github.com/sbyx/hnetd.git
PKG_MAINTAINER:=Steven Barth <cyrus@openwrt.org>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# Spammy debug builds for now
CMAKE_OPTIONS += -DL_LEVEL=7

# OpenWRT target
CMAKE_OPTIONS += -DBACKEND=openwrt

define Package/hnetd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=HNCP Homenet daemon
  URL:=https://github.com/sbyx/hnetd
  DEPENDS:=+odhcpd +odhcp6c +netifd
  DEPENDS+=+@IPV6
endef

define Package/hnet-full
  SECTION:=net
  CATEGORY:=Network
  TITLE:=HNCP Homenet metapackage (hnetd + ohybridproxy + babels)
  URL:=https://github.com/sbyx/hnetd
  DEPENDS:=+odhcpd +odhcp6c +netifd +hnetd +ohybridproxy +babels
  DEPENDS+=+@IPV6
endef

define Package/hnetd/description
This package provides a daemon which implementats distributed prefix assignment
and service discovery for a home network consisting of multiple routers
connected to multiple service providers. It provides a netifd protocol "hnet"
for use in /etc/config/network.
endef

define Package/hnetd/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hnetd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt/hnet.sh $(1)/lib/netifd/proto
	ln -s hnetd $(1)/usr/sbin/hnet-call
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/hnetd.init $(1)/etc/init.d/hnetd
	$(INSTALL_BIN) ./files/ohp-script $(1)/usr/sbin/hnetd-ohp-script
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/generic/hnetd-routing $(1)/usr/sbin/hnetd-routing
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/hnetd.defaults $(1)/etc/uci-defaults/x-hnetd.defaults
endef

define Package/hnet-full/install
	true
endef

define Package/hnetd/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	(. /etc/uci-defaults/x-hnetd.defaults) && rm -f /etc/uci-defaults/x-hnetd.defaults
	[ -x /etc/init.d/dnsmasq ] && /etc/init.d/dnsmasq restart
	/etc/init.d/hnetd enable
	/etc/init.d/hnetd start
}
exit 0
endef

$(eval $(call BuildPackage,hnetd))
$(eval $(call BuildPackage,hnet-full))
