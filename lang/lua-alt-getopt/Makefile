#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-alt-getopt
PKG_VERSION:=0.7.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/4260/
PKG_MD5SUM:=f504578b1287ea02759add231b972812

PKG_MAINTAINER:=Alex R <alex@totalwebservices.net>
PKG_LICENSE=MIT

LUA_MODULE_PATH:=/usr/lib/lua

include $(INCLUDE_DIR)/package.mk

define Package/lua-alt-getopt
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=lua-alt-getopt
  URL:=http://luaforge.net/projects/alt-getopt/
  DEPENDS:=+lua
endef

define Package/lua-alt-getopt/description
	Process application arguments the same way as getopt_long
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/lua-alt-getopt/install
	$(INSTALL_DIR) $(1)/$(LUA_MODULE_PATH)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/alt_getopt.lua $(1)/$(LUA_MODULE_PATH)/alt_getopt.lua
endef

$(eval $(call BuildPackage,lua-alt-getopt))
