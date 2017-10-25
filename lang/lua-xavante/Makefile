#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-xavante
PKG_VERSION:=2.3.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Dirk Chang <dirk@kooiot.com>
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MIRROR_HASH:=0ab254d4bb8ce9556ad8fc2a1b4aef739ec3bb3e1f343400b20435e2ab8e686f
PKG_SOURCE_URL:=https://github.com/keplerproject/xavante.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=9825b905133e14d37a4c179f2d02367ab93f1ef6
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/lua-xavante
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Xavante Web Server
  URL:=http://keplerproject.github.io/xavante/
  DEPENDS:= +lua
endef

define Package/lua-xavante/description
  Xavante is a Lua HTTP 1.1 Web server that uses a modular architecture based on URI mapped handlers.
endef


define Build/Configure
endef

define Build/Compile
endef

define Build/Install
endef

define Package/lua-xavante/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/sajax/sajax.lua $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/xavante/xavante.lua $(1)/usr/lib/lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/xavante
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/xavante/{cgiluahandler,encoding,filehandler,httpd,mime,patternhandler,redirecthandler,vhostshandler,indexhandler,urlhandler,ruleshandler}.lua $(1)/usr/lib/lua/xavante
endef

$(eval $(call BuildPackage,lua-xavante))
