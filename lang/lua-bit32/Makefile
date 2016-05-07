#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-bit32
PKG_VERSION:=5.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=git://github.com/keplerproject/lua-compat-5.2.git
PKG_SOURCE_VERSION:=bitlib-5.3.0

PKG_MAINTAINER:=Alex R <alex@totalwebservices.net>
PKG_LICENSE=MIT

LUA_MODULE_PATH:=/usr/lib/lua
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/lua-bit32
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=lua-bit32
  URL:=http://www.lua.org/manual/5.2/manual.html#6.7
  DEPENDS:= +lua
endef

define Package/lua-bit32/description
   bit32 is the native Lua 5.2 bit manipulation library, in the version from Lua 5.3; it is compatible with Lua 5.1, 5.2 and 5.3.
endef

TARGET_CFLAGS += $(FPIC) -shared
TARGET_LDFLAGS += -llua

LUA_MODULE_PATH:=/usr/lib/lua

define Build/Configure
endef

define Build/Compile
	$(TARGET_CROSS)gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -I $(PKG_BUILD_DIR)/c-api/ -o $(PKG_BUILD_DIR)/bit32.so $(PKG_BUILD_DIR)/lbitlib.c
endef

define Package/lua-bit32/install
	$(INSTALL_DIR) $(1)/$(LUA_MODULE_PATH)/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bit32.so $(1)/$(LUA_MODULE_PATH)/
endef

$(eval $(call BuildPackage,lua-bit32))
