#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
# 

include $(TOPDIR)/rules.mk

PKG_NAME:=luarocks
PKG_VERSION:=2.2.2
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/keplerproject/luarocks.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)

PKG_MAINTAINER:=Amr Hassan <amr.hassan@gmail.com>
PKG_INSTALL=1
PKG_BUILD_DEPENDS:=lua/host luac/host
PKG_LICENSE=GPL

include $(INCLUDE_DIR)/package.mk

define Package/luarocks
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=luarocks
  URL:=https://github.com/keplerproject/luarocks
  DEPENDS:=+lua +luac +liblua +luasocket +unzip +curl +luasec
endef

define Package/luarocks/description
	LuaRocks is a deployment and management system for Lua modules.
endef

# My custom args, copied and modified from SDK_ROOT/include/package-defaults.mk
CONFIGURE_ARGS = \
    --prefix=$(CONFIGURE_PREFIX) \
    --sysconfdir=/etc \
    --with-lua=$(STAGING_DIR_HOSTPKG)

CONFIGURE_VARS = \
	LUAROCKS_UNAME_S="Linux" \
	LUAROCKS_UNAME_M="$(ARCH)"

define Build/Compile
	$(call Build/Compile/Default,build)
endef

define Package/luarocks/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/luarocks-5.1 $(1)/usr/bin/luarocks
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/luarocks-admin-5.1 $(1)/usr/bin/luarocks-admin
	$(CP) $(PKG_INSTALL_DIR)/usr/share $(1)/usr/share
	$(CP) $(PKG_INSTALL_DIR)/etc $(1)/etc
endef

$(eval $(call BuildPackage,luarocks))
