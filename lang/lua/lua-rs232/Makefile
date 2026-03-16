#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-rs232
PKG_SOURCE_DATE:=2019-11-20
PKG_SOURCE_VERSION:=c106c94d1a5a84e8582c936528303528608776c2
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/srdgame/librs232
PKG_MIRROR_HASH:=d507ce004a9b02b8d8a31d0c348eb9c481f1030153c941131aeff0dd3046a419

PKG_MAINTAINER:=Dirk Chang <dirk@kooiot.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=lua/host
PKG_BUILD_FLAGS:=gc-sections

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

TARGET_LDFLAGS += -Wl,--as-needed
MAKE_FLAGS += luadir='$$$${prefix}/lib/lua' luaexecdir='$$$${exec_prefix}/lib/lua'

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/librs232
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/librs232/rs232* $(1)/usr/include/librs232
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/librs232* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/luars232* $(1)/usr/lib/lua
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/librs232.pc $(1)/usr/lib/pkgconfig
endef

define Package/lua-rs232/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/librs232.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/luars232* $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,lua-rs232))
