#
# Copyright (C) 2012-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=ohybridproxy
PKG_SOURCE_VERSION:=8a28ae92c97099e771c9ede5641e3782ae809c27
PKG_VERSION:=2016-06-28-$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/sbyx/ohybridproxy.git
PKG_MAINTAINER:=Steven Barth <cyrus@openwrt.org>
PKG_LICENSE:=GPL-2.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# Spammy debug builds for now
CMAKE_OPTIONS += -DL_LEVEL=7

define Package/ohybridproxy
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=mdns/dns hybrid-proxy
  URL:=https://github.com/sbyx/ohybridproxy
  DEPENDS+=+libubox +mdnsd
endef

define Package/ohybridproxy/description
 This package provides a statically configured daemon for translating DNS
 requests to Multicast DNS and back again.
endef

define Package/ohybridproxy/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ohybridproxy $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_DATA) ./files/ohybridproxy.config $(1)/etc/config/ohybridproxy
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/ohybridproxy.init $(1)/etc/init.d/ohybridproxy
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/ohybridproxy.hotplug $(1)/etc/hotplug.d/iface/ohybridproxy
endef

$(eval $(call BuildPackage,ohybridproxy))

define Package/zonestitcher
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=dynamically combine multiple DNS zones into one
  URL:=https://github.com/sbyx/ohybridproxy
  DEPENDS+=+libubox
endef

define Package/zonestitcher/description
 This package provides a statically configured daemon for translating DNS
 requests to Multicast DNS and back again.
endef

define Package/zonestitcher/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/zonestitcher $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,zonestitcher))
