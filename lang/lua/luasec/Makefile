#
# Copyright (C) 2009-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luasec
PKG_VERSION:=1.3.2
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/brunoos/luasec/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=97293092ba385ab390decb6678bc8cbeffd5899bfbc49eb7ef4aa00f5e31c3d4

MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/luasec/default
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=LuaSec
  URL:=https://github.com/brunoos/luasec
endef

define Package/luasec
  $(Package/luasec/default)
  DEPENDS:=+lua +libopenssl +luasocket
  VARIANT:=lua-51
  DEFAULT_VARIANT:=1
endef

define Package/luasec5.4
  $(Package/luasec/default)
  TITLE+= (Lua 5.4)
  DEPENDS:=+lua5.4 +libopenssl +luasocket5.4
  VARIANT:=lua-54
endef

define Package/luasec/default/description
  LuaSec is a binding for OpenSSL library to provide TLS/SSL communication.
endef
Package/luasec/description     = $(Package/luasec/default/description)
Package/luasec5.4/description = $(Package/luasec/default/description)

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

TARGET_CFLAGS += $(FPIC) -I$(LUA_INCDIR)
TARGET_LDFLAGS += $(FPIC) -l$(LUA_LIBNAME)

MAKE_FLAGS += \
	LD="$(TARGET_CC)" \
	INC_PATH="" \
	LIB_PATH="" \
	LUACPATH="$(PKG_INSTALL_DIR)$(LUA_INSTALL_DIR)" \
	LUAPATH="$(PKG_INSTALL_DIR)$(LUA_INSTALL_DIR)"

define Build/Compile
$(call Build/Compile/Default,linux)
endef

define Package/luasec/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/ssl.so $(1)/usr/lib/lua/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/ssl.lua $(1)/usr/lib/lua/
	$(INSTALL_DIR) $(1)/usr/lib/lua/ssl
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/ssl/https.lua $(1)/usr/lib/lua/ssl/
endef

define Package/luasec5.4/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/5.4
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/5.4/ssl.so $(1)/usr/lib/lua/5.4/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/5.4/ssl.lua $(1)/usr/lib/lua/5.4/
	$(INSTALL_DIR) $(1)/usr/lib/lua/5.4/ssl
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/5.4/ssl/https.lua $(1)/usr/lib/lua/5.4/ssl/
endef

$(eval $(call BuildPackage,luasec))
$(eval $(call BuildPackage,luasec5.4))
