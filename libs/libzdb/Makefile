#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libzdb
PKG_VERSION:=3.2.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.tildeslash.com/libzdb/dist/
PKG_HASH:=b9a7b59a0a9f53dc87ce1b5a919f21b8cd6448c04a9157bccef1e3c1dffd3ff1

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=libzdb/host
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk
# libzdb needs to find iconv when linking to libmariadb
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/libzdb
    SECTION:=libs
    CATEGORY:=Libraries
    TITLE:=A thread-safe multi database connection pool library
    URL:=https://www.tildeslash.com/libzdb/
    DEPENDS:=+libsqlite3 +libpq +libmysqlclient +zlib +libpthread +libopenssl
endef

define Package/libzdb/description
   zdb is a database library with thread-safe connection pooling. The library can connect
   transparently to multiple database systems. It has zero runtime configuration and connections
   are specified via a URL scheme. A modern object-oriented API is provided.
   zdb supports MySQL, PostgreSQL, SQLite, and Oracle.
   NOTE: This package does not include Oracle support.
endef

CONFIGURE_ARGS += \
	--disable-profiling \
	--enable-optimized \
	--enable-protected \
	--enable-sqliteunlock \
	--enable-openssl

CONFIGURE_VARS += \
	libzdb_cv_setjmp_available=yes \
	libzdb_cv_vsnprintf_c11_conformant=yes

define Hooks/HostConfigure/Pre
endef

define Host/Configure
endef

define Host/Compile
	$(HOSTCC) $(HOST_BUILD_DIR)/tools/filterh/lex.yy.c -o $(HOST_BUILD_DIR)/tools/bin/filterh
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/bin
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/tools/bin/filterh $(STAGING_DIR_HOSTPKG)/bin
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/zdb
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/zdb/* $(1)/usr/include/zdb
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzdb* $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/zdb.pc $(1)/usr/lib/pkgconfig
endef

define Package/libzdb/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzdb.so* $(1)/usr/lib
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libzdb))
