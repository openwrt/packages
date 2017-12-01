#
# Copyright (C) 2017 Alexander Couzens <lynxis@fe80.eu>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luaosc
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Alexander Couzens <lynxis@fe80.eu>
PKG_LICENSE:=GPL-3.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://files.luaforge.net/releases/$(PKG_NAME)/$(PKG_NAME)/$(PKG_VERSION)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_MD5SUM:=47e38d392fee3e374946b6096d998665

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/luaosc
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua OpenSoundControl library
  URL:=http://luaforge.net/projects/luaosc/
  DEPENDS:= +lua +luasocket +lualpack
endef

define Package/luaosc/description
  A library implementing the OpenSoundControl protocol.
endef

define Build/Configure
endef

define Build/Compile
endef

define Build/Install
endef

define Package/luaosc/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/osc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/osc.lua $(1)/usr/lib/lua/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/osc/*.lua $(1)/usr/lib/lua/osc
endef

$(eval $(call BuildPackage,luaosc))
