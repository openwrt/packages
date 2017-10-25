#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-wsapi
PKG_VERSION:=1.6.1
PKG_RELEASE:=1
PKG_MAINTAINER:=Dirk Chang <dirk@kooiot.com>
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MIRROR_HASH:=0e52ca377c135c8db1f824841e1a36c1ef7e4b4a594a5b70a2f402586901ca1f
PKG_SOURCE_URL:=https://github.com/keplerproject/wsapi.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=eed8338401196cc155e59280adbe58d78933ead0
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/lua-wsapi/Default
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua WSAPI
  URL:=https://keplerproject.github.io/wsapi/
  DEPENDS:= +lua
endef

define Package/lua-wsapi/Default/description
  WSAPI is an API that abstracts the web server from Lua web applications
endef


define Package/lua-wsapi-base
$(call Package/lua-wsapi/Default)
  TITLE+= base
  DEPENDS+= +luafilesystem
  VARIANT:=base
endef

define Package/lua-wsapi-base/description
$(call Package/lua-wsapi/Default/description)
 .
 This package contains the basic stuff.
endef

define Package/lua-wsapi-xavante
$(call Package/lua-wsapi/Default)
  TITLE+= xavante
  DEPENDS+= +lua-wsapi-base +lua-xavante
  VARIANT:=xavante
endef

define Package/lua-wsapi-xavante/description
$(call Package/lua-wsapi/Default/description)
 .
 This package contains the Xavante stuff.
endef

define Build/Configure
endef

define Build/Compile
endef

define Build/Install
endef

define Package/lua-wsapi-base/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/wsapi.lua $(1)/usr/lib/lua
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/launcher/wsapi.cgi $(1)/usr/bin

	$(INSTALL_DIR) $(1)/usr/lib/lua/wsapi
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/wsapi/{common,request,response,util,cgi,sapi,ringer,mock}.lua $(1)/usr/lib/lua/wsapi
endef

define Package/lua-wsapi-xavante/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/launcher/wsapi $(1)/usr/bin

	$(INSTALL_DIR) $(1)/usr/lib/lua/wsapi
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/wsapi/xavante.lua $(1)/usr/lib/lua/wsapi
endef


$(eval $(call BuildPackage,lua-wsapi-base))
$(eval $(call BuildPackage,lua-wsapi-xavante))
