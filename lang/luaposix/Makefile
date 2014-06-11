#
# Copyright (C) 2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luaposix
PKG_VERSION:=v31
PKG_RELEASE:=1

PKG_SOURCE:=release-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/luaposix/luaposix/archive/
PKG_MD5SUM:=a25ff76d54bbbebf7a1f3b20c9806ee3
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-release-$(PKG_VERSION)
PKG_REMOVE_FILES:=aclocal.m4
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/luaposix
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=luaposix
  URL:=http://luaforge.net/projects/luaposix/
  DEPENDS:=+lua +librt +luabitop
  PKG_BUILD_DEPENDS:=+lua/host
endef

define Package/luaposix/description
  luaposix is a general POSIX library for Lua providing access
  to various low level libc functions.
endef

TARGET_CFLAGS += -DLUA_USE_LINUX $(FPIC) -std=gnu99

ifneq ($(CONFIG_USE_EGLIBC),)
  ifeq ($(CONFIG_EGLIBC_OPTION_EGLIBC_UTMP),)
    TARGET_CFLAGS += -DNO_GETLOGIN
  endif
endif


define Package/luaposix/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ext/posix/.libs/posix_c.so $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/posix.lua $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,luaposix))
