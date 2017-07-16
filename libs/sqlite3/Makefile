#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sqlite
PKG_VERSION:=3190300
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-autoconf-$(PKG_VERSION).tar.gz
PKG_HASH:=06129c03dced9f87733a8cba408871bd60673b8f93b920ba8d815efab0a06301
PKG_SOURCE_URL:=http://www.sqlite.org/2017/

PKG_LICENSE:=PUBLICDOMAIN
PKG_LICENSE_FILES:=

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-autoconf-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=libncurses libreadline

PKG_FIXUP:=autoreconf

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/sqlite3/Default
  SUBMENU:=database
  TITLE:=SQLite (v3.x) database engine
  URL:=http://www.sqlite.org/
  MAINTAINER:=Etienne CHAMPETIER <champetier.etienne@gmail.com>
endef

define Package/sqlite3/Default/description
 SQLite is a small C library that implements a self-contained, embeddable,
 zero-configuration SQL database engine.
endef

define Package/libsqlite3
  $(call Package/sqlite3/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libpthread
  TITLE+= (library)
endef

define Package/libsqlite3/description
$(call Package/sqlite3/Default/description)
 This package contains the SQLite (v3.x) shared library, used by other
 programs.
endef

define Package/sqlite3-cli
  $(call Package/sqlite3/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libsqlite3 +libncurses +libreadline
  TITLE+= (cli)
endef

define Package/sqlite3-cli/description
$(call Package/sqlite3/Default/description)
 This package contains a terminal-based front-end to the SQLite (v3.x) library
 that can evaluate queries interactively and display the results in multiple
 formats.
endef

TARGET_CFLAGS += $(FPIC) \
	-DSQLITE_ENABLE_UNLOCK_NOTIFY=1 \
	-DHAVE_ISNAN=1 \
	-DHAVE_MALLOC_USABLE_SIZE=1

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--disable-editline

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/sqlite3{,ext}.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsqlite3.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/sqlite3.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libsqlite3/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsqlite3.so.* $(1)/usr/lib/
endef

define Package/sqlite3-cli/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sqlite3 $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libsqlite3))
$(eval $(call BuildPackage,sqlite3-cli))
