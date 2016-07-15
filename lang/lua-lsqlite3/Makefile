#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lsqlite3
PKG_VERSION:=0.9.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).zip
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=http://lua.sqlite.org/index.cgi/zip/lsqlite3_fsl09w.zip
PKG_MD5SUM:=8e16ef4fda82eb73295bf2f1050d14f1

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_NAME)_fsl09w.zip

include $(INCLUDE_DIR)/package.mk

define Package/lsqlite3
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua wrapper for the SQLite3 library
  URL:=http://lua.sqlite.org
  DEPENDS:= +lua +libsqlite3
endef

define Package/lsqlite3/description
 LuaSQLite3 is a thin wrapper around the public domain SQLite3 database engine.
endef

TARGET_CFLAGS += $(FPIC) -std=gnu99
TARGET_CPPFLAGS += -DLUA_USE_LINUX
TARGET_LDFLAGS += -llua -lsqlite3 -lpthread

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) \
		-c $(PKG_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/lsqlite3.c \
		-o $(PKG_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/lsqlite3.o \
		-DSQLITE_VERSION="$(PKG_VERSION)"
	$(TARGET_CC) $(TARGET_LDFLAGS) -shared \
		$(PKG_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/lsqlite3.o \
		-o $(PKG_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/lsqlite3.so
endef

define Package/lsqlite3/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(CP) $(PKG_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/*.so $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,lsqlite3))
