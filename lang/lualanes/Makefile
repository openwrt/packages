#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lualanes
PKG_REV:=aa9bfcf2dd49f55f11b27e7c21d5b75d81ccfc7e
PKG_VERSION:=3.9.4
PKG_RELEASE=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_REV).tar.gz
PKG_MIRROR_HASH:=e9b053e627edaf7ef229af176177bf2bd0edd31b69690ba7c1e6be41041ffd07
PKG_SOURCE_URL:=https://github.com/LuaLanes/lanes.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_BUILD_DEPENDS:=lua/host

include $(INCLUDE_DIR)/package.mk

define Package/lualanes
	SUBMENU:=Lua
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=LuaLanes
	URL:=http://luaforge.net/projects/lanes/
	DEPENDS:=+lua +luac +liblua +libpthread
	MAINTAINER:=Vladimir Malyutin <first-leon@yandex.ru>
endef

define Package/lualanes/description
	Lanes is a lightweight, native, lazy evaluating multithreading library for Lua 5.1 and 5.2.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) all \
        CC="$(TARGET_CC)" \
        LUA="$(STAGING_DIR_HOSTPKG)/bin/lua" \
        LUAC="$(STAGING_DIR_HOSTPKG)/bin/luac" \
        OPT_FLAGS="$(TARGET_CFLAGS) --std=c99 -Dpthread_yield=sched_yield"
endef

define Package/lualanes/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/lanes.lua $(1)/usr/lib/lua/
	$(INSTALL_DIR) $(1)/usr/lib/lua/lanes
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/lanes/core.so $(1)/usr/lib/lua/lanes/core.so
endef

$(eval $(call BuildPackage,lualanes))
