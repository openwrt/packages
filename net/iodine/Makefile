#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iodine
PKG_VERSION:=0.8.0
PKG_RELEASE:=5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://code.kryo.se/iodine/
PKG_HASH:=546e92cf8617f7970ea81c850b1063eb189c68c406d0c6a67e02c55e72e714c6

PKG_MAINTAINER:=Uwe Kleine-König <uwe+openwrt@kleine-koenig.org>
PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=README
PKG_CPE_ID:=cpe:/a:kryo:iodine

include $(INCLUDE_DIR)/package.mk

define Package/iodine/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Firewall Tunnel
  DEPENDS:= +kmod-tun +zlib
  TITLE:=IP over DNS tunneling
  URL:=http://code.kryo.se/iodine/
endef

define Package/iodine
  $(call Package/iodine/Default)
  TITLE+= client version
endef

define Package/iodine/description
 iodine client version
endef

define Package/iodined
  $(call Package/iodine/Default)
  TITLE+= server version
endef

define Package/iodined/description
 iodine server version
endef

MAKE_FLAGS += \
	TARGETOS="Linux"

define Build/Configure
endef

define Package/iodine/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/iodine $(1)/usr/sbin
endef

define Package/iodined/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/iodined.init $(1)/etc/init.d/iodined
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/iodined.config $(1)/etc/config/iodined
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/iodined $(1)/usr/sbin
endef

define Package/iodined/conffiles
/etc/config/iodined
endef

$(eval $(call BuildPackage,iodine))
$(eval $(call BuildPackage,iodined))
