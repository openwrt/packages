#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-rs232
PKG_VERSION:=1.0.3
PKG_RELEASE:=1
PKG_MAINTAINER:=Dirk Chang <dirk@kooiot.com>
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/srdgame/librs232.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=a9d463181e7f7034fe6a55bc38e845fb04fa93ba
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/lua-rs232
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua Serial Library
  URL:=https://github.com/srdgame/librs232
  DEPENDS:= +lua
endef

define Package/lua-rs232/description
  multiplatform library for serial communications over RS-232
endef

CONFIGURE_ARGS += \
	--with-lua-inc=$(STAGING_DIR)/usr/include \
	--with-lua-lib=$(STAGING_DIR)/usr/lib

#define Build/Configure
#	( cd "$(PKG_BUILD_DIR)"; ./autogen.sh )
#	$(call Build/Configure/Default)
#endef
define Build/Configure
endef

define Build/Compile
	(cd "$(PKG_BUILD_DIR)"; $(TARGET_CC)  src/rs232.c src/rs232_posix.c bindings/lua/luars232.c -DLUAROCKS_HACK -std=gnu99 -I./include -I$(STAGING_DIR)/usr/include -L$(STAGING_DIR)/usr/lib -fPIC -shared -o luars232.so)
endef

define Build/Install
endef

define Package/lua-rs232/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luars232.so $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,lua-rs232))
