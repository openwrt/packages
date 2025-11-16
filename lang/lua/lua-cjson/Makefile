#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-cjson
PKG_VERSION:=2.1.0
PKG_RELEASE:=5
PKG_MAINTAINER:=Dirk Chang <dirk@kooiot.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://kyne.au/~mark/software/download/
PKG_HASH:=51bc69cd55931e0cba2ceae39e9efa2483f4292da3a88a1ed470eda829f6c778

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

HOST_BUILD_DEPENDS:=lua/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/lua-cjson/default
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua CJSON parser
  URL:=https://github.com/mpx/lua-cjson
endef

define Package/lua-cjson
  $(Package/lua-cjson/default)
  DEPENDS+=+liblua
  VARIANT:=lua-51
endef

define Package/lua-cjson-lua5.3
  $(Package/lua-cjson/default)
  DEPENDS+=+liblua5.3
  VARIANT:=lua-53
endef

define Package/lua-cjson-lua5.4
  $(Package/lua-cjson/default)
  DEPENDS+=+liblua5.4
  VARIANT:=lua-54
endef

define Package/lua-cjson/default/description
  Lua CJSON is a fast JSON encoding/parsing module for Lua.
endef

Package/lua-cjson/description = $(Package/lua-cjson/default/description)
Package/lua-cjson-lua5.3/description = $(Package/lua-cjson/default/description)
Package/lua-cjson-lua5.4/description = $(Package/lua-cjson/default/description)

CMAKE_OPTIONS += \
	-DUSE_LUA=ON

CMAKE_HOST_OPTIONS += \
	-DLUA_MATH_LIBRARY=m

ifeq ($(BUILD_VARIANT),lua-53)
  CMAKE_OPTIONS += -DUSE_LUA53=ON
endif

ifeq ($(BUILD_VARIANT),lua-54)
  CMAKE_OPTIONS += -DUSE_LUA54=ON
endif

define Package/lua-cjson/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cjson.so $(1)/usr/lib/lua/

	$(INSTALL_DIR) $(1)/usr/lib/lua/cjson
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lua/cjson/util.lua $(1)/usr/lib/lua/cjson
endef

define Package/lua-cjson-lua5.3/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.3
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cjson.so $(1)/usr/local/lib/lua/5.3
endef

define Package/lua-cjson-lua5.4/install
	$(INSTALL_DIR) $(1)/usr/local/lib/lua/5.4
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cjson.so $(1)/usr/local/lib/lua/5.4
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,lua-cjson))
$(eval $(call BuildPackage,lua-cjson-lua5.3))
$(eval $(call BuildPackage,lua-cjson-lua5.4))
