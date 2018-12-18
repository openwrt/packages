#
# Copyright (C) 2006-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sqlite
PKG_VERSION:=3260000
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-autoconf-$(PKG_VERSION).tar.gz
PKG_HASH:=5daa6a3fb7d1e8c767cd59c4ded8da6e4b00c61d3b466d0685e35c4dd6d7bf5d
PKG_SOURCE_URL:=https://www.sqlite.org/2018/

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
  DEPENDS:=+libpthread +zlib
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

# On uClibc libm needs to be linked in for ISNAN()
TARGET_LDFLAGS += $(if $(CONFIG_USE_UCLIBC),-lm)

TARGET_CFLAGS += $(FPIC) \
	-DSQLITE_ENABLE_UNLOCK_NOTIFY=1 \
	-DHAVE_ISNAN=1 \
	-DHAVE_MALLOC_USABLE_SIZE=1

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--disable-editline \
	--disable-static-shell

CONFIGURE_VARS += \
	config_BUILD_CC="$(HOSTCC)" \
	config_BUILD_CFLAGS="-O2" \
	config_TARGET_CC="$(TARGET_CC)" \
	config_TARGET_CFLAGS="$(TARGET_CFLAGS)" \
	config_TARGET_READLINE_INC="$(TARGET_CPPFLAGS)" \
	config_TARGET_READLINE_LIBS="$(TARGET_LDFLAGS) -lreadline -lncurses" \

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
