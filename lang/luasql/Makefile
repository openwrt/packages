#
# Copyright (C) 2010-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luasql
PKG_VERSION:=2.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/keplerproject/luasql.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=docs/us/license.html
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/luasql/Default
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua SQL binding
  URL:=http://keplerproject.github.io/luasql/
  DEPENDS:= +lua
endef

define Package/luasql/Default/description
 LuaSQL is a simple interface from Lua to a DBMS.
endef


define Package/luasql-mysql
$(call Package/luasql/Default)
  TITLE+= for MySQL
  DEPENDS+= +libmysqlclient
  VARIANT:=mysql
endef

define Package/luasql-mysql/description
$(call Package/luasql/Default/description)
 .
 This package contains the MySQL binding.
endef


define Package/luasql-pgsql
$(call Package/luasql/Default)
  TITLE+= for PostgreSQL
  DEPENDS+= +libpq
  VARIANT:=postgres
endef

define Package/luasql-pgsql/description
$(call Package/luasql/Default/description)
 .
 This package contains the PostgreSQL binding.
endef


define Package/luasql-sqlite3
$(call Package/luasql/Default)
  TITLE+= for SQLite 3
  DEPENDS+= +libsqlite3
  VARIANT:=sqlite3
endef

define Package/luasql-sqlite3/description
$(call Package/luasql/Default/description)
 .
 This package contains the SQLite 3 binding.
endef


TARGET_CFLAGS += $(FPIC) -std=gnu99
TARGET_CPPFLAGS += -DLUA_USE_LINUX

ifeq ($(BUILD_VARIANT),mysql)
  TARGET_CPPFLAGS += -I$(STAGING_DIR)/usr/include/mysql
  TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib/mysql -lmysqlclient -lz
endif

ifeq ($(BUILD_VARIANT),postgres)
  TARGET_LDFLAGS += -lpq
endif

ifeq ($(BUILD_VARIANT),sqlite3)
  TARGET_LDFLAGS += -lsqlite3 -lpthread
endif

MAKE_FLAGS += \
	T="$(BUILD_VARIANT)" \
	DRIVER_INCS="$(TARGET_CPPFLAGS)" \
	DRIVER_LIBS="$(TARGET_LDFLAGS)" \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
	lib

define Package/Install/Default
	$(INSTALL_DIR) $(1)/usr/lib/lua/luasql
	$(CP) $(PKG_BUILD_DIR)/src/*.so $(1)/usr/lib/lua/luasql/
endef

Package/luasql-mysql/install = $(Package/Install/Default)
Package/luasql-pgsql/install = $(Package/Install/Default)
Package/luasql-sqlite3/install = $(Package/Install/Default)

$(eval $(call BuildPackage,luasql-mysql))
$(eval $(call BuildPackage,luasql-pgsql))
$(eval $(call BuildPackage,luasql-sqlite3))
