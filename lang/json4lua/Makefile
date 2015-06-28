#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#  

include $(TOPDIR)/rules.mk

PKG_NAME:=json4lua
PKG_VERSION:=0.9.53
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/amrhassan/json4lua.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)

PKG_MAINTAINER:=Amr Hassan <amr.hassan@gmail.com>
PKG_LICENSE=MIT

LUA_MODULE_PATH:=/usr/lib/lua

include $(INCLUDE_DIR)/package.mk

define Package/json4lua
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=json4lua
  URL:=https://github.com/amrhassan/json4lua
  DEPENDS:=+lua +luasocket
endef

define Package/json4lua/description
	JSON and JSONRPC for Lua
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/json4lua/install
	$(INSTALL_DIR) $(1)/$(LUA_MODULE_PATH)/json
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/json/json.lua $(1)/$(LUA_MODULE_PATH)/json.lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/json/rpc.lua $(1)/$(LUA_MODULE_PATH)/json/rpc.lua
endef

$(eval $(call BuildPackage,json4lua))
