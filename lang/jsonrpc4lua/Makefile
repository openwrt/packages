#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#  

include $(TOPDIR)/rules.mk

PKG_NAME:=jsonrpc4lua
PKG_VERSION:=1.0.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/pdxmeshnet/jsonrpc4lua.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)

PKG_MAINTAINER:=Alex R <alex@totalwebservices.net>
PKG_LICENSE=MIT

LUA_MODULE_PATH:=/usr/lib/lua

include $(INCLUDE_DIR)/package.mk

define Package/jsonrpc4lua
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=jsonrpc4lua
  URL:=https://github.com/pdxmeshnet/jsonrpc4lua
  DEPENDS:=+lua +luasocket +lua-cjson
endef

define Package/jsonrpc4lua/description
	JSONRPC for Lua
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/jsonrpc4lua/install
	$(INSTALL_DIR) $(1)/$(LUA_MODULE_PATH)/json
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/json/rpc.lua $(1)/$(LUA_MODULE_PATH)/json/rpc.lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/json/rpcserver.lua $(1)/$(LUA_MODULE_PATH)/json/rpcserver.lua
endef

$(eval $(call BuildPackage,jsonrpc4lua))
