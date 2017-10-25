#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-md5
PKG_VERSION:=1.2
PKG_RELEASE:=1
PKG_MAINTAINER:=Dirk Chang <dirk@kooiot.com>
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MIRROR_HASH:=89a186d9e8bb43a6d45207eeba2883600854ea05befda55b38f7ac215b0d5615
PKG_SOURCE_URL:=https://github.com/keplerproject/md5.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=024b65738b4434860777fc43d7cacaefea29ec60
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/lua-md5
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua-MD5
  URL:=https://github.com/keplerproject/md5
  DEPENDS:=+lua
endef

define Package/lua-md5/description
  MD5 offers basic cryptographic facilities for Lua
endef

TARGET_CFLAGS += $(FPIC)

# add make variable overrides here
MAKE_FLAGS +=

define Build/Configure
endef

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

define Build/Install
	$(MAKE) -C $(PKG_BUILD_DIR) \
		LUA_LIBDIR="$(PKG_INSTALL_DIR)/usr/lib/lua" \
		LUA_DIR="$(PKG_INSTALL_DIR)/usr/lib/lua" \
		install
endef

define Package/lua-md5/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/md5.lua $(1)/usr/lib/lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/md5
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/core.so $(1)/usr/lib/lua/md5/core.so
endef

$(eval $(call BuildPackage,lua-md5))
