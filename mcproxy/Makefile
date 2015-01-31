#
# Copyright (C) 2014-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mcproxy
PKG_SOURCE_VERSION:=b7bd2d0809a0d1f177181c361b9a6c83e193b79a
PKG_VERSION:=2014-12-31-$(PKG_SOURCE_VERSION)
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://github.com/mcproxy/mcproxy.git
PKG_MAINTAINER:=Steven Barth <cyrus@openwrt.org>
PKG_LICENSE:=GPL-2.0+

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/mcproxy
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=Multicast Proxy for IGMP/MLD
  URL:=http://mcproxy.realmv6.org
  DEPENDS:=+libpthread +libstdcpp @(!GCC_VERSION_4_4&&!GCC_VERSION_4_6)
endef

define Package/mcproxy/description
 mcproxy is a free & open source implementation of the IGMP/MLD proxy function (see  RFC 4605) for Linux systems.
 It operates on the kernel tables for multicast routing and allows for multiple instantiations,
 as well as dynamically changing downstream interfaces.
endef

define Package/mcproxy/conffiles
/etc/mcproxy.conf
/etc/config/mcproxy
endef

define Package/mcproxy/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/mcproxy.conf $(1)/etc/mcproxy.conf
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/mcproxy.config $(1)/etc/config/mcproxy
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mcproxy.init $(1)/etc/init.d/mcproxy
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mcproxy-bin $(1)/usr/sbin/mcproxy
endef

$(eval $(call BuildPackage,mcproxy))
