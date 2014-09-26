#
# Copyright (C) 2012-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=hnetd
PKG_SOURCE_VERSION:=0c1d55d03983c726aaad010738236c2da64ca7df
PKG_VERSION:=2014-09-26-$(PKG_SOURCE_VERSION)
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
  TITLE:=HNCP Homenet metapackage
  URL:=https://github.com/sbyx/hnetd
  DEPENDS:=+hnetd +luci-app-hnet
  # Routing
  DEPENDS+=+babels
  # Service discovery
  DEPENDS+=+ohybridproxy
  # Distributed PCP support
  DEPENDS+=+miniupnpd +minimalist-pcproxy
endef

define Package/luci-app-hnet
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=HNCP Homenet configuration and visualization
  DEPENDS:=+hnetd
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
	ln -s hnetd $(1)/usr/sbin/hnet-ifresolve
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/hnetd.init $(1)/etc/init.d/hnetd
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/hnet.config $(1)/etc/config/hnet
	$(INSTALL_BIN) ./files/ohp-script $(1)/usr/sbin/hnetd-ohp-script
	$(INSTALL_BIN) ./files/pcp-script $(1)/usr/sbin/hnetd-pcp-script
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/generic/hnetd-routing $(1)/usr/sbin/hnetd-routing
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/hnetd.defaults $(1)/etc/uci-defaults/x-hnetd.defaults
endef

define Package/hnet-full/install
	true
endef

define Package/luci-app-hnet/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/www
	$(CP) -R $(PKG_BUILD_DIR)/openwrt/luci/luasrc/* $(1)/usr/lib/lua/luci/
	$(CP) -R $(PKG_BUILD_DIR)/openwrt/luci/htdocs/* $(1)/www/
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
$(eval $(call BuildPackage,luci-app-hnet))
