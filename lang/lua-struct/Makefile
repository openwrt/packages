#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-struct
PKG_VERSION:=0.2
PKG_RELEASE:=1

_BASENAME:=struct

PKG_SOURCE:=$(_BASENAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.inf.puc-rio.br/~roberto/struct
PKG_MD5SUM:=99384bf1f54457ec9f796ad0b539d19c
PKG_MAINTAINER:=Anton D. Kachalov <mouse@yandex-team.ru>
PKG_LICENSE:=MIT

PKG_INSTALL:=1

UNPACK_CMD=tar -C $(1) -xf "$(DL_DIR)/$(PKG_SOURCE)"

include $(INCLUDE_DIR)/package.mk

define Package/lua-struct
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua binary struct pack/unpack
  URL:=http://www.inf.puc-rio.br/~roberto/struct/
  DEPENDS:=+lua
endef

define Package/lua-struct/description
  This library offers basic facilities to convert Lua values to and from C structs.
endef

TARGET_CFLAGS += $(FPIC)

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		PREFIX="$(STAGING_DIR)/usr" \
		LUA_LIBDIR="$(STAGING_DIR)/usr/lib/lua" \
		clean
	$(MAKE) -C $(PKG_BUILD_DIR) \
		PREFIX="$(STAGING_DIR)/usr" \
		LUA_LIBDIR="$(STAGING_DIR)/usr/lib/lua" \
		LIB_OPTION="-shared" \
		CC="$(TARGET_CROSS)gcc" \
		CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
		all
endef

define Package/lua-struct/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/struct.so $(1)/usr/lib/lua/struct.so
endef

$(eval $(call BuildPackage,lua-struct))
