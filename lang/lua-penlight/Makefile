#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-penlight
PKG_VERSION:=1.6.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/Penlight-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/stevedonovan/Penlight/tar.gz/$(PKG_VERSION)?
PKG_HASH:=a552d0a314f7aa94c9579746996a7aad4ed59f3187f33b4735d3e323e27354b0
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md

include $(INCLUDE_DIR)/package.mk

define Package/lua-penlight
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Penlight
  URL:=http://stevedonovan.github.io/Penlight/api/manual/01-introduction.md.html
  DEPENDS:=+luafilesystem
  MAINTAINER:=Karl Palsson <karlp@etactica.com>
endef

define Package/lua-penlight/description
  It is often said of Lua that it does not include batteries.
  Penlight is the batteries.
endef

define Build/Compile
	echo "Nothing to compile, pure lua package"
endef

define Package/lua-penlight/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(CP) $(PKG_BUILD_DIR)/lua/pl $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,lua-penlight))
