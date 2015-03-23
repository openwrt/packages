#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-penlight
PKG_VERSION:=1.3.2
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/Penlight-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/stevedonovan/Penlight/archive/
PKG_MD5SUM:=0315a39834bb6fab07741ec04ede1bf4
PKG_LICENSE:=MIT
PKG_LICENSE_FILE:=LICENSE.md

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Penlight
  URL:=http://stevedonovan.github.io/Penlight/api/manual/01-introduction.md.html
  DEPENDS:=+luafilesystem
  MAINTAINER:= Karl Palsson <karlp@remake.is>
endef

define Package/$(PKG_NAME)/description
  It is often said of Lua that it does not include batteries.
  Penlight is the batteries.
endef

define Build/Compile
	echo "Nothing to compile, pure lua package"
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(CP) $(PKG_BUILD_DIR)/lua/pl $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
