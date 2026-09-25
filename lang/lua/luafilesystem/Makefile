#
# Copyright (C) 2008-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luafilesystem
PKG_VERSION:=1.9.0
PKG_RELEASE:=2
PKG_LICENSE:=MIT

PKG_MIRROR_HASH:=a64d8299c7c875bd2183f82f9a71f6fcc7610ee7377add0b6069fea3d7355073
PKG_SOURCE_URL:=https://github.com/lunarmodules/luafilesystem.git
PKG_SOURCE_VERSION:=v$(subst .,_,$(PKG_VERSION))
PKG_SOURCE_PROTO:=git

include $(INCLUDE_DIR)/package.mk

define Package/luafilesystem/default
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=LuaFileSystem
  URL:=https://lunarmodules.github.io/luafilesystem/
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
endef

define Package/luafilesystem
  $(Package/luafilesystem/default)
  DEPENDS:=+liblua
  VARIANT:=lua-51
  DEFAULT_VARIANT:=1
endef

define Package/luafilesystem5.4
  $(Package/luafilesystem/default)
  TITLE+= (Lua 5.4)
  DEPENDS:=+liblua5.4
  VARIANT:=lua-54
endef

define Package/luafilesystem/default/description
 This package contains the LuaFileSystem library, a set of portable
 functions for directory creation, listing and deletion and for file
 locking.
endef
Package/luafilesystem/description     = $(Package/luafilesystem/default/description)
Package/luafilesystem5.4/description = $(Package/luafilesystem/default/description)

ifeq ($(BUILD_VARIANT),lua-51)
  LUA_VERSION:=5.1
  LUA_LIBNAME:=lua
  LUA_INCDIR:=$(STAGING_DIR)/usr/include
  LUA_INSTALL_DIR:=/usr/lib/lua
endif

ifeq ($(BUILD_VARIANT),lua-54)
  LUA_VERSION:=5.4
  LUA_LIBNAME:=lua5.4
  LUA_INCDIR:=$(STAGING_DIR)/usr/include/lua5.4
  LUA_INSTALL_DIR:=/usr/lib/lua/5.4
endif

define Build/Configure
endef

TARGET_CFLAGS += $(FPIC) $(TARGET_CPPFLAGS) -I$(LUA_INCDIR)

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -std=gnu99" \
		LDFLAGS="$(TARGET_LDFLAGS) -l$(LUA_LIBNAME)"
	$(TARGET_CROSS)ar r $(PKG_BUILD_DIR)/src/luafilesystem.a $(PKG_BUILD_DIR)/src/lfs.o
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include
	$(INSTALL_DIR) $(STAGING_DIR)$(LUA_INSTALL_DIR)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/lfs.h $(STAGING_DIR)/usr/include
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/lfs.so $(STAGING_DIR)$(LUA_INSTALL_DIR)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/luafilesystem.a $(STAGING_DIR)$(LUA_INSTALL_DIR)
endef

define Package/luafilesystem/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/lfs.so $(1)/usr/lib/lua/lfs.so
endef

define Package/luafilesystem5.4/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/5.4
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/lfs.so $(1)/usr/lib/lua/5.4/lfs.so
endef

$(eval $(call BuildPackage,luafilesystem))
$(eval $(call BuildPackage,luafilesystem5.4))
