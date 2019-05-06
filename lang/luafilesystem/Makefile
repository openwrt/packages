#
# Copyright (C) 2008-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luafilesystem
PKG_VERSION:=1.7.0.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MIRROR_HASH:=f109017711dd77d74a39bd1c0975be7edf726da0265f16496ea468481fac0b85
PKG_SOURCE_URL:=https://github.com/keplerproject/luafilesystem.git
PKG_SOURCE_VERSION:=de87218e9798c4dd1a40d65403d99e9e82e1cfa0
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/luafilesystem
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=LuaFileSystem
  URL:=http://keplerproject.github.com/luafilesystem/
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
  DEPENDS:=+liblua
endef

define Package/luafilesystem/description
 This package contains the LuaFileSystem library, a set of portable
 functions for directory creation, listing and deletion and for file
 locking.
endef

define Build/Configure
endef

TARGET_CFLAGS += $(FPIC) $(TARGET_CPPFLAGS)

TARGET_LDFLAGS += -llua

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -std=gnu99" \
		LDFLAGS="$(TARGET_LDFLAGS)"
	$(TARGET_CROSS)ar r $(PKG_BUILD_DIR)/src/luafilesystem.a $(PKG_BUILD_DIR)/src/lfs.o
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include
	$(INSTALL_DIR) $(STAGING_DIR)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/lfs.h $(STAGING_DIR)/usr/include
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/lfs.so $(STAGING_DIR)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/luafilesystem.a $(STAGING_DIR)/usr/lib/lua
endef

define Package/luafilesystem/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/lfs.so $(1)/usr/lib/lua/lfs.so
endef

$(eval $(call BuildPackage,luafilesystem))
