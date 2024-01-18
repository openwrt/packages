#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lualanes
PKG_VERSION:=3.16.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/LuaLanes/lanes.git
PKG_SOURCE_VERSION:=489f7caf9ed893c1e8efc5c1b6ecb757a2131932
PKG_MIRROR_HASH:=667042a2d773bb4d6139abca1ed2b62c2b6b3f4dd7c5446914de548625ea08f8

PKG_MAINTAINER:=Vladimir Malyutin <first-leon@yandex.ru>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYRIGHT

PKG_BUILD_DEPENDS:=lua/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/lualanes
	SUBMENU:=Lua
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=LuaLanes
	URL:=http://lualanes.github.io/lanes/
	DEPENDS:=+lua +luac +liblua +libpthread
endef

define Package/lualanes/description
Lua Lanes is a Lua extension library providing the possibility to run
multiple Lua states in parallel. It is intended to be used for optimizing
performance on multicore CPU's and to study ways to make Lua programs
naturally parallel to begin with.

Lanes is included into your software by the regular require "lanes" method.
No C side programming is needed; all APIs are Lua side, and most existing
extension modules should work seamlessly together with the multiple lanes.

Lanes supports Lua 5.1, 5.2 and 5.3
endef

define Package/lualanes/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/lua/lmod/lanes.lua $(1)/usr/lib/lua/
	$(INSTALL_DIR) $(1)/usr/lib/lua/lanes
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/lua/cmod/core.so $(1)/usr/lib/lua/lanes/core.so
endef

$(eval $(call BuildPackage,lualanes))
