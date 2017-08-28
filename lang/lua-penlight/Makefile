#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-penlight
PKG_VERSION:=1.5.4
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/stevedonovan/Penlight
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=cd9f25981b12022b66180a3b8df46840be1b3e2a857b8d9909b2d5601be0ead4
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
