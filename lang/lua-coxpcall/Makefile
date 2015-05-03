#
# Copyright (C) 2009-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-coxpcall
PKG_VERSION:=1.15.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Dirk Chang <dirk@kooiot.com>
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/keplerproject/coxpcall.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=979257892884816c97391dfd7b0a7b30dcc8f479
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/lua-coxpcall
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua-Coxpcall
  URL:=https://github.com/keplerproject/coxpcall
  DEPENDS:=+lua
endef

define Package/lua-coxpcall/description
  Coxpcall encapsulates the protected calls with a coroutine based loop,
  so errors can be dealed without the usual pcall/xpcall issues with coroutines.
endef

TARGET_CFLAGS += $(FPIC)
# add make variable overrides here
MAKE_FLAGS +=

define Build/Configure
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		T="$(BUILD_VARIANT)" \
		LUA_DIR="$(PKG_INSTALL_DIR)/usr/lib/lua" \
		install
endef

define Package/lua-coxpcall/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/coxpcall.lua $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,lua-coxpcall))
