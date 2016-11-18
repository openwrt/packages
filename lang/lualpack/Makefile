#
# Copyright (C) 2017 Alexander Couzens <lynxis@fe80.eu>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lualpack
PKG_VERSION:=2007-06-29
PKG_RELEASE:=1
PKG_MAINTAINER:=Alexander Couzens <lynxis@fe80.eu>
PKG_LICENSE:=PublicDomain MIT

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/lynxis/$(PKG_NAME)/archive/
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_MD5SUM:=f08fb262815a6ad8dee76b7233f0faed

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/lualpack
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua lpack libary to pack and unpack binary values
  URL:=http://luaforge.net/projects/lualpack/
  DEPENDS:= +lua
endef

define Package/lualpack/description
  Implements simple binary pack and unpack.
endef

TARGET_CFLAGS += -fPIC -I$(STAGING_DIR)/usr/include/

# build make target so
MAKE_FLAGS += so

define Build/Install
endef

define Package/lualpack/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pack.so $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,lualpack))
