#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-inifile
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=git://github.com/bartbes/love-misc-libs.git
PKG_SOURCE_VERSION:=master

PKG_MAINTAINER:=Alex R <alex@totalwebservices.net>
PKG_LICENSE=Simplified BSD license

LUA_MODULE_PATH:=/usr/lib/lua

include $(INCLUDE_DIR)/package.mk

define Package/lua-inifile
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=lua-inifile
  URL:=http://docs.bartbes.com/inifile
  DEPENDS:=+lua
endef

define Package/lua-inifile/description
	Inifile is a lua library for parsing and writing ini files.
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/lua-inifile/install
	$(INSTALL_DIR) $(1)/$(LUA_MODULE_PATH)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/inifile/inifile.lua $(1)/$(LUA_MODULE_PATH)/inifile.lua
endef

$(eval $(call BuildPackage,lua-inifile))
