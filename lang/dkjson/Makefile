#
# Copyright (C) 20013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dkjson
PKG_VERSION:=2.5
PKG_RELEASE:=3

PKG_SOURCE_URL:=https://github.com/LuaDist/dkjson.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=e72ba0c9f5d8b8746fc306f6189a819dbb5cd0be
PKG_LICENSE:=MIT
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.bz2
PKG_MIRROR_HASH:=e80673611e25ce63a95ea0f7a9c407868903fd78536d6c80f1763f2cf9488030
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_SOURCE_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/dkjson
	SUBMENU:=Lua
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=DKJSON
	URL:=http://dkolf.de/src/dkjson-lua.fsl/home
	MAINTAINER:=Lars Gierth <larsg@systemli.org>
	DEPENDS:=+lua
endef

define Package/dkjson/description
	Lua JSON parser/serializer with UTF-8 support
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/dkjson/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dkjson.lua $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,dkjson))
