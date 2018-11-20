#
# Copyright (C) 2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luasoap
PKG_VERSION:=4.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/tomasguisasola/luasoap/tar.gz/v4_0?
PKG_HASH:=d53c669eb41883c594eed3d3a87f4a1ff45c2f6bcdfb9517785390a4c2117e05
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-4_0

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
	$(INSTALL_DIR) $(1)/usr/lib/lua/soap/client
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/client/https.lua $(1)/usr/lib/lua/soap/client/
	$(INSTALL_DIR) $(1)/usr/lib/lua/soap/tests
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/tests/test{,-http,-server}.lua $(1)/usr/lib/lua/soap/tests/
endef

$(eval $(call BuildPackage,luasoap))
