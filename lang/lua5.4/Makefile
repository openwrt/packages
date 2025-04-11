#
# Copyright (C) 2006-2023 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua
PKG_VERSION:=5.4.7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.lua.org/ftp/ \
	https://www.tecgraf.puc-rio.br/lua/ftp/
PKG_HASH:=9fbf5e28ef86c69858f6d3d34eccc32e911c1a28b4120ff3e84aaa70cfbf1e30
PKG_BUILD_PARALLEL:=1

PKG_MAINTAINER:=Christian Marangi <ansuelsmth@gmail.com>

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYRIGHT
PKG_CPE_ID:=cpe:/a:lua:lua

HOST_PATCH_DIR := ./patches-host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/lua5.4/Default
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua programming language (version 5.4)
  URL:=https://www.lua.org/
endef

define Package/lua5.4/Default/description
  Lua is a powerful, efficient, lightweight, embeddable scripting language. It
  supports procedural programming, object-oriented programming, functional
  programming, data-driven programming, and data description.
endef

define Package/liblua5.4
$(call Package/lua5.4/Default)
  SUBMENU:=
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= (libraries)
  ABI_VERSION:=5.4
endef

define Package/liblua5.4/description
$(call Package/lua5.4/Default/description)
 This package contains the Lua shared libraries, needed by other programs.
endef

define Package/lua5.4
$(call Package/lua5.4/Default)
  DEPENDS:=+liblua5.4
  TITLE+= (interpreter)
endef

define Package/lua5.4/description
$(call Package/lua5.4/Default/description)
  This package contains the Lua language interpreter.
endef

define Package/luac5.4
$(call Package/lua5.4/Default)
  DEPENDS:=+liblua5.4
  TITLE+= (compiler)
endef

define Package/luac5.4/description
$(call Package/lua5.4/Default/description)
  This package contains the Lua language compiler.
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	mv $(PKG_BUILD_DIR)/doc/lua.1 $(PKG_BUILD_DIR)/doc/lua5.4.1
	mv $(PKG_BUILD_DIR)/doc/luac.1 $(PKG_BUILD_DIR)/doc/luac5.4.1
endef

TARGET_CFLAGS += -DLUA_USE_LINUX $(FPIC) -std=gnu99

define Build/Compile
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CROSS)gcc" \
		AR="$(TARGET_CROSS)ar rcu" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		INSTALL_ROOT=/usr \
		CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS)" \
		PKG_VERSION=$(PKG_VERSION) \
		linux
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		INSTALL_TOP="$(PKG_INSTALL_DIR)/usr" \
		install
endef

define Host/Prepare
	$(call Host/Prepare/Default)
	mv $(HOST_BUILD_DIR)/doc/lua.1 $(HOST_BUILD_DIR)/doc/lua5.4.1
	mv $(HOST_BUILD_DIR)/doc/luac.1 $(HOST_BUILD_DIR)/doc/luac5.4.1
endef

define Host/Configure
	$(SED) 's,"/usr/local/","$(STAGING_DIR_HOSTPKG)/",' $(HOST_BUILD_DIR)/src/luaconf.h
endef

ifeq ($(HOST_OS),Darwin)
	LUA_OS:=macosx
else
	ifeq ($(HOST_OS),FreeBSD)
		LUA_OS:=freebsd
	else
		LUA_OS:=linux
	endif
endif

define Host/Compile
	$(MAKE) -C $(HOST_BUILD_DIR) \
		CC="$(HOSTCC) $(HOST_FPIC) -std=gnu99" \
		$(LUA_OS)
endef

define Host/Install
	$(MAKE) -C $(HOST_BUILD_DIR) \
		INSTALL_TOP="$(STAGING_DIR_HOSTPKG)" \
		install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/lua5.4 $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/lua5.4/lua{,lib,conf}.h $(1)/usr/include/lua5.4/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/lua5.4/lua.hpp $(1)/usr/include/lua5.4/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/lua5.4/lauxlib.h $(1)/usr/include/lua5.4/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liblua5.4.{a,so*} $(1)/usr/lib/
	$(LN) liblua5.4.so.0.0.0 $(1)/usr/lib/liblualib5.4.so
endef

define Package/liblua5.4/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liblua5.4.so* $(1)/usr/lib/
endef

define Package/lua5.4/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/lua5.4 $(1)/usr/bin/
endef

define Package/luac5.4/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/luac5.4 $(1)/usr/bin/
endef

$(eval $(call BuildPackage,liblua5.4))
$(eval $(call BuildPackage,lua5.4))
$(eval $(call BuildPackage,luac5.4))
$(eval $(call HostBuild))
