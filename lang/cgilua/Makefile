#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cgilua
PKG_VERSION:=5.1.4
PKG_RELEASE:=1

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/keplerproject/cgilua/archive/
PKG_MD5SUM:=ed162ca341d0f1cd16868c80bed3da4c

PKG_MAINTAINER:=Alex R <alex@totalwebservices.net>
PKG_LICENSE=MIT

LUA_MODULE_PATH:=/usr/lib/lua
LUA_BIN_PATH:=/usr/bin

include $(INCLUDE_DIR)/package.mk

define Package/cgilua
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=cgilua
  URL:=https://github.com/keplerproject/cgilua
  DEPENDS:=+lua +luafilesystem
endef

define Package/cgilua/description
	CGILua is a tool for creating dynamic HTML pages and manipulating input data from Web forms.
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/cgilua/install
	$(INSTALL_DIR) $(1)/$(LUA_MODULE_PATH)/cgilua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/cgilua/cgilua.lua $(1)/$(LUA_MODULE_PATH)/cgilua.lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/cgilua/authentication.lua $(1)/$(LUA_MODULE_PATH)/cgilua/authentication.lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/cgilua/cookies.lua $(1)/$(LUA_MODULE_PATH)/cgilua/cookies.lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/cgilua/dispatcher.lua $(1)/$(LUA_MODULE_PATH)/cgilua/dispatcher.lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/cgilua/loader.lua $(1)/$(LUA_MODULE_PATH)/cgilua/loader.lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/cgilua/lp.lua $(1)/$(LUA_MODULE_PATH)/cgilua/lp.lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/cgilua/mime.lua $(1)/$(LUA_MODULE_PATH)/cgilua/mime.lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/cgilua/post.lua $(1)/$(LUA_MODULE_PATH)/cgilua/post.lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/cgilua/readuntil.lua $(1)/$(LUA_MODULE_PATH)/cgilua/readuntil.lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/cgilua/serialize.lua $(1)/$(LUA_MODULE_PATH)/cgilua/serialize.lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/cgilua/session.lua $(1)/$(LUA_MODULE_PATH)/cgilua/session.lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/cgilua/urlcode.lua $(1)/$(LUA_MODULE_PATH)/cgilua/urlcode.lua
	$(INSTALL_DIR) $(1)/$(LUA_BIN_PATH)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/launchers/cgilua.cgi $(1)/$(LUA_BIN_PATH)/cgilua.cgi
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/launchers/cgilua.fcgi $(1)/$(LUA_BIN_PATH)/cgilua.fcgi
endef

$(eval $(call BuildPackage,cgilua))
