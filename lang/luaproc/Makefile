#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luaproc
PKG_VERSION:=1.0
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=git://github.com/askyrme/luaproc.git
PKG_SOURCE_VERSION:=1.0-4

PKG_MAINTAINER:=Alex <alex@maximum.guru>
PKG_LICENSE=MIT

LUA_MODULE_PATH:=/usr/lib/lua
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/luaproc
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=luaproc
  URL:=https://github.com/askyrme/luaproc
  DEPENDS:= +lua +libpthread
endef

define Package/luaproc/description
   luaproc is a concurrent programming library for Lua
endef

TARGET_CFLAGS += $(FPIC) -shared
TARGET_LDFLAGS += -llua -lpthread

LUA_MODULE_PATH:=/usr/lib/lua

define Build/Compile
	$(TARGET_CROSS)gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -o $(PKG_BUILD_DIR)/luaproc.so $(PKG_BUILD_DIR)/src/lpsched.c $(PKG_BUILD_DIR)/src/luaproc.c
endef

define Package/luaproc/install
	$(INSTALL_DIR) $(1)/$(LUA_MODULE_PATH)/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luaproc.so $(1)/$(LUA_MODULE_PATH)/
endef

$(eval $(call BuildPackage,luaproc))
