#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=apr-util
PKG_VERSION:=1.6.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@APACHE/apr/
PKG_HASH:=d3e12f7b6ad12687572a3a39475545a072608f4ba03a6ce8a3778f607dd0035b
PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de>
PKG_LICENSE:=Apache License
PKG_CPE_ID:=cpe:/a:apache:apr-util

PKG_BUILD_PARALLEL:=1

PKG_CONFIG_DEPENDS := \
	CONFIG_PACKAGE_libaprutil-crypto-openssl \
	CONFIG_PACKAGE_libaprutil-dbd-mysql \
	CONFIG_PACKAGE_libaprutil-dbd-odbc \
	CONFIG_PACKAGE_libaprutil-dbd-pgsql \
 	CONFIG_PACKAGE_libaprutil-dbd-sqlite3 \
 	CONFIG_PACKAGE_libaprutil-ldap \
	CONFIG_PACKAGE_libaprutil-dbm-gdbm

PKG_FIXUP:=autoreconf

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/libaprutil/Default
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=http://apr.apache.org/
endef

define Package/libaprutil
  $(call Package/libaprutil/Default)
  MENU:=1
  DEPENDS:=+libapr +libexpat +libuuid $(ICONV_DEPENDS)
  TITLE:=Apache Portable Runtime Utility Library
endef

TARGET_CFLAGS += $(FPIC)
TARGET_CPPFLAGS += -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE

CONFIGURE_ARGS += \
	--with-apr="$(STAGING_DIR)/usr/bin/apr-1-config" \
	--with-expat="$(STAGING_DIR)/usr" \
	--without-sqlite2

ifneq ($(SDK)$(CONFIG_PACKAGE_libaprutil-crypto-openssl),)
  CONFIGURE_ARGS += \
	--with-crypto \
	--with-crypto-openssl="$(STAGING_DIR)/usr"
else
  CONFIGURE_ARGS += --without-crypto
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_libaprutil-dbd-mysql),)
  CONFIGURE_ARGS += \
	--with-mysql="$(STAGING_DIR)/usr"
else
  CONFIGURE_ARGS += --without-mysql
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_libaprutil-dbd-odbc),)
  CONFIGURE_ARGS += \
        --with-odbc="$(STAGING_DIR)/usr"
else
  CONFIGURE_ARGS += --without-odbc
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_libaprutil-dbd-pgsql),)
  CONFIGURE_ARGS += \
        --with-pgsql="$(STAGING_DIR)/usr"
else
  CONFIGURE_ARGS += --without-pgsql
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_libaprutil-dbd-sqlite3),)
  CONFIGURE_ARGS += \
	--with-sqlite3="$(STAGING_DIR)/usr"
else
  CONFIGURE_ARGS += --without-sqlite3
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_libaprutil-dbm-gdbm),)
  CONFIGURE_ARGS += \
        --with-dbm=gdbm \
	--with-gdbm="$(STAGING_DIR)/usr"
else
  CONFIGURE_ARGS += --without-gdbm
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_libaprutil-ldap),)
  CONFIGURE_ARGS += \
        --with-ldap
else
  CONFIGURE_ARGS += --without-ldap
endif

ifdef $(CONFIG_BUILD_NLS)
	CONFIGURE_ARGS += --with-iconv="$(ICONV_PREFIX)"
else
	CONFIGURE_ARGS += --without-iconv
endif

#CONFIGURE_VARS += \
#	APR_BUILD_DIR="$(STAGING_DIR)/usr/share/build-1"

#	ac_cv_file_dbd_apr_dbd_mysql_c=no \
#	ac_cv_path_ODBC_CONFIG= \
#	APR_BUILD_DIR="$(STAGING_DIR)/usr/share/build-1"

MAKE_FLAGS += \
	APRUTIL_LIBS="$(TARGET_LDFLAGS) -lexpat $(if $(ICONV_FULL),-liconv) -lapr-1 -luuid -lm -lcrypt"

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/include/apr-1/ $(1)/usr/lib  $(1)/usr/lib/pkgconfig/
	$(CP)   $(PKG_INSTALL_DIR)/usr/bin/apu-1-config \
	 	$(1)/usr/bin/
	$(CP)   $(PKG_INSTALL_DIR)/usr/include/apr-1/* \
		$(1)/usr/include/apr-1/
	$(CP)   $(PKG_INSTALL_DIR)/usr/lib/libaprutil-1.{la,a,so*} \
		$(1)/usr/lib/
	$(CP)   $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/apr-util-1.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/libaprutil/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libaprutil-1.so.* $(1)/usr/lib/
endef

define BuildPlugin
  define Package/libaprutil-$(1)
    $(call Package/libaprutil/Default)
    DEPENDS:=+libaprutil
    ifneq ($(4),)
      DEPENDS+= +$(4)
    endif
    TITLE:=$(2) plugin
  endef

  define Package/libaprutil-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/lib/apr-util-1
	for p in $(3); do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/apr-util-1/apr_$$$$$$$${p}*.so $$(1)/usr/lib/apr-util-1; \
	done
  endef

  $$(eval $$(call BuildPackage,libaprutil-$(1)))
endef

$(eval $(call BuildPackage,libaprutil))
$(eval $(call BuildPlugin,crypto-openssl,Crypto OpenSSL,crypto_openssl,libopenssl))
$(eval $(call BuildPlugin,dbd-mysql,Database MySQL Module,dbd_mysql,libmariadb))
$(eval $(call BuildPlugin,dbd-odbc,Database ODBC Module,dbd_odbc,unixodbc))
$(eval $(call BuildPlugin,dbd-pgsql,Database PostgreSQL Module,dbd_pgsql,libpq))
$(eval $(call BuildPlugin,dbd-sqlite3,Database SQLite3 Module,dbd_sqlite3,libsqlite3))
$(eval $(call BuildPlugin,dbm-gdbm,DBM Module,dbm_gdbm,libgdbm))
$(eval $(call BuildPlugin,ldap,LDAP Module,ldap,libopenldap))

