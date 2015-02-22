#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libzdb
PKG_VERSION:=3.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.tildeslash.com/libzdb/dist/
PKG_MD5SUM:=3bb9efff10a1f3ebc5b76c1055c48635

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_BUILD_DEPENDS:=libzdb/host

include $(INCLUDE_DIR)/package.mk

define Package/libzdb
    SECTION:=libs
    CATEGORY:=Libraries
    TITLE:=A thread-safe multi database connection pool library
    MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
    URL:=http://www.tildeslash.com/libzdb/
    DEPENDS:=+libsqlite3 +libpq +libmysqlclient +zlib +libpthread +libopenssl
endef

define Package/libzdb/description
   zdb is a database library with thread-safe connection pooling. The library can connect
   transparently to multiple database systems. It has zero runtime configuration and connections
   are specified via a URL scheme. A modern object-oriented API is provided.
   zdb supports MySQL, PostgreSQL, SQLite, and Oracle.
   NOTE: This package does not include Oracle support.
endef

CONFIGURE_ARGS += --disable-profiling \
		    --enable-optimized \
		    --with-mysql \
		    --with-postgresql \
		    --with-sqlite \
		    --enable-sqliteunlock \
		    --enable-openssl

TARGET_CPPFLAGS += -std=c99

include $(INCLUDE_DIR)/host-build.mk

define Hooks/HostConfigure/Pre
endef

define Host/Configure
endef

define Host/Compile
	$(HOSTCC) $(HOST_BUILD_DIR)/tools/filterh/lex.yy.c -o $(HOST_BUILD_DIR)/tools/bin/filterh
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOST)/bin
	$(CP) $(HOST_BUILD_DIR)/tools/bin/filterh $(STAGING_DIR_HOST)/bin/
endef

$(eval $(call HostBuild))

define Build/Compile
	$(call Build/Compile/Default)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/zdb
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/zdb/ $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzdb* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/zdb.pc $(1)/usr/lib/pkgconfig
endef

define Package/libzdb/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzdb.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libzdb))
