#
# Copyright (C) 2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luaexpat
PKG_VERSION:=1.5.2
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/lunarmodules/luaexpat
PKG_MIRROR_HASH:=d479e41ea28b71ede214754d0cde87e6582022fcdd3981c928b41491062835c8

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENCE
PKG_CPE_ID:=cpe:/a:matthewwild:luaexpat

include $(INCLUDE_DIR)/package.mk

define Package/luaexpat/default
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=LuaExpat
  URL:=https://lunarmodules.github.io/luaexpat/
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
endef

define Package/luaexpat
  $(Package/luaexpat/default)
  DEPENDS:=+lua +libexpat
  VARIANT:=lua-51
  DEFAULT_VARIANT:=1
endef

define Package/luaexpat5.4
  $(Package/luaexpat/default)
  TITLE+= (Lua 5.4)
  DEPENDS:=+lua5.4 +libexpat
  VARIANT:=lua-54
endef

define Package/luaexpat/default/description
  LuaExpat is a SAX XML parser based on the Expat library.
endef
Package/luaexpat/description     = $(Package/luaexpat/default/description)
Package/luaexpat5.4/description = $(Package/luaexpat/default/description)

ifeq ($(BUILD_VARIANT),lua-51)
  LUA_INCDIR:=$(STAGING_DIR)/usr/include
  LUA_LIBNAME:=lua
  LUA_INSTALL_DIR:=/usr/lib/lua
endif

ifeq ($(BUILD_VARIANT),lua-54)
  LUA_INCDIR:=$(STAGING_DIR)/usr/include/lua5.4
  LUA_LIBNAME:=lua5.4
  LUA_INSTALL_DIR:=/usr/lib/lua/5.4
endif

define Build/Configure
endef

define Build/Compile
	$(CP) files/compat-5.1r5 $(PKG_BUILD_DIR)/compat-5.1r5
	$(MAKE) -C $(PKG_BUILD_DIR) \
	EXPAT_INC="-I$(STAGING_DIR)/usr/include/" \
	LUA_INC="-I$(LUA_INCDIR)" \
	LUA_LIBDIR="$(STAGING_DIR)/usr/lib/" \
	COMPAT_DIR="$(PKG_BUILD_DIR)/compat-5.1r5" \
	LDFLAGS="-shared $(TARGET_LDFLAGS) -l$(LUA_LIBNAME)" \
	CC="$(TARGET_CC) $(TARGET_CFLAGS) $(FPIC) -std=c99" \
	LD="$(TARGET_CROSS)ld -shared"
endef

define Package/luaexpat/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/lxp.so $(1)/usr/lib/lua/lxp.so
	$(INSTALL_DIR) $(1)/usr/lib/lua/lxp
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/lxp/lom.lua $(1)/usr/lib/lua/lxp
endef

define Package/luaexpat5.4/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/5.4
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/lxp.so $(1)/usr/lib/lua/5.4/lxp.so
	$(INSTALL_DIR) $(1)/usr/lib/lua/5.4/lxp
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/lxp/lom.lua $(1)/usr/lib/lua/5.4/lxp
endef

$(eval $(call BuildPackage,luaexpat))
$(eval $(call BuildPackage,luaexpat5.4))
