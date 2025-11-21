#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mbtools
PKG_SOURCE_DATE:=2014-10-29
PKG_SOURCE_VERSION:=149e9c69cec180f18cf8781cf5285b97352bf719
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/webstack/mbtools
PKG_MIRROR_HASH:=cd2ed34f194262d9e4eecf67cf1d0c9ac55e05795367a6014f11325b6bae9552

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/mbtools
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Modbus tools
  DEPENDS:=+glib2 +libmodbus
endef

define Package/mbtools/description
  Modbus tools based on libmodbus to log data fetched by a master/client or
  received by a slave/server (writing of registers). mbcollect is able to act
  as client or server (in TCP or RTU)
endef

define Package/mbtools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mbrecorder $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mbcollect $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/src/mbcollect.ini $(1)/etc
endef

$(eval $(call BuildPackage,mbtools))
