#
# Copyright (C) 2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luasoap
PKG_VERSION:=4.0.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/tomasguisasola/luasoap
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=ecd82fe9d7c62c6870f042ba65ce57054d68193779af9461cb4d95b83983bf80

PKG_MAINTAINER:=Liu Peng <pengliu@credosemi.com>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/luasoap
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=LuaSOAP
  URL:=https://github.com/tomasguisasola/luasoap
  DEPENDS:=+lua +luaexpat +luasec +luasocket
  PKGARCH:=all
endef

define Package/luasoap/description
  LuaSOAP is a library of functions to deal with SOAP.
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luasoap/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/soap.lua $(1)/usr/lib/lua/
	$(INSTALL_DIR) $(1)/usr/lib/lua/soap
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/{client,server}.lua $(1)/usr/lib/lua/soap/
	$(INSTALL_DIR) $(1)/usr/lib/lua/soap/tests
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/tests/test{,-http,-server,-wsdl}.lua $(1)/usr/lib/lua/soap/tests/
endef

$(eval $(call BuildPackage,luasoap))
