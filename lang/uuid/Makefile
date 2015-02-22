#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=uuid
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PKG_SOURCE:=version_$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Tieske/$(PKG_NAME)/archive/
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-version_$(PKG_VERSION)
PKG_MAINTAINER:=Amr Hassan <amr.hassan@gmail.com>
PKG_LICENSE=Apache-2.0

LUA_MODULE_PATH:=/usr/lib/lua

include $(INCLUDE_DIR)/package.mk

define Package/uuid
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=uuid
  URL:=https://github.com/Tieske/uuid
  DEPENDS:=+lua +luasocket
endef

define Package/uuid/description
	A pure Lua uuid generator
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/uuid/install
	$(INSTALL_DIR) $(1)/$(LUA_MODULE_PATH)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/uuid.lua $(1)/$(LUA_MODULE_PATH)/uuid.lua
endef

$(eval $(call BuildPackage,uuid))
