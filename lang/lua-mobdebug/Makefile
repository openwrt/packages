#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-mobdebug
PKG_VERSION:=0.61
PKG_RELEASE:=1
PKG_MAINTAINER:=Dirk Chang <dirk@kooiot.com>
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MIRROR_HASH:=947876d6b8e234a21d1e918523d66546282011718f2260d5e1f10ebf60c851cb
PKG_SOURCE_URL:=https://github.com/pkulchenko/MobDebug.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=9a03aa59696647ba3b7f9ae2f29a9f28532a4feb
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/lua-mobdebug
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua-MobDebug
  URL:=https://github.com/pkulchenko/MobDebug
  DEPENDS:=+lua
endef

define Package/lua-mobdebug/description
  MobDebug is a remote debugger for Lua (including Lua 5.1, Lua 5.2, Lua 5.3, and LuaJIT 2.x).
endef

define Build/Configure
endef

define Build/Compile
endef

define Build/Install
endef

# add make variable overrides here
MAKE_FLAGS +=

define Package/lua-mobdebug/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/mobdebug.lua $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,lua-mobdebug))
