#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=postgresql
PKG_VERSION:=9.4.4
PKG_RELEASE:=1
PKG_MAINTAINER:=Jo-Philipp Wich <jow@openwrt.org>
PKG_LICENSE:=PostgreSQL

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=\
	http://ftp9.us.postgresql.org/pub/mirrors/postgresql/source/v$(PKG_VERSION) \
	http://ftp.be.postgresql.org/postgresql/source/v$(PKG_VERSION) \
	ftp://ftp-archives.postgresql.org/pub/source/v$(PKG_VERSION)
PKG_MD5SUM:=1fe952c44ed26d7e6a335cf991a9c1c6
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_FIXUP:=autoreconf
PKG_MACRO_PATHS:=config

include $(INCLUDE_DIR)/package.mk

define Package/libpq
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+zlib +libreadline +libpthread +libncurses +shadow-utils +shadow-su
  TITLE:=PostgreSQL client library
  URL:=http://www.postgresql.org/
  SUBMENU:=database
endef

define Package/libpq/description
PostgreSQL client library.
endef

define Package/pgsql-cli
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libpq +USE_UCLIBC:librt
  TITLE:=Command Line Interface (CLI) to PostgreSQL databases
  URL:=http://www.postgresql.org/
  SUBMENU:=database
endef

define Package/pgsql-cli/description
Command Line Interface (CLI) to PostgreSQL databases.
endef

define Package/pgsql-server
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libpq +USE_UCLIBC:librt
  TITLE:=PostgreSQL databases Server
  URL:=http://www.postgresql.org/
  SUBMENU:=database
  USERID:=postgres=5432:postgres=5432
endef

define Package/pgsql-server/description
PostgreSQL databases Server.
endef

PGSQL_CONFIG_VARS:= \
	pgac_cv_snprintf_long_long_int_format="%lld" \
	pgac_cv_snprintf_size_t_support=yes

ifeq ($(CONFIG_USE_UCLIBC),y)
# PostgreSQL does not build against uClibc with locales
# enabled, due to an uClibc bug, see
# http://lists.uclibc.org/pipermail/uclibc/2014-April/048326.html
# so overwrite automatic detection and disable locale support
PGSQL_CONFIG_VARS+= \
		pgac_cv_type_locale_t=no
endif

TARGET_CONFIGURE_OPTS+=$(PGSQL_CONFIG_VARS)

# Need a native ecpg ,pg_config, and zic for build
define Build/Configure
	(cd $(PKG_BUILD_DIR); rm -f config.cache; \
		$(PGSQL_CONFIG_VARS) \
		./configure \
			--prefix=/usr \
			--exec-prefix=/usr \
			--bindir=/usr/bin \
			--datadir=/usr/share \
			--includedir=/usr/include \
			--infodir=/usr/share/info \
			--libdir=/usr/lib \
			--libexecdir=/usr/lib \
			--localstatedir=/var \
			--mandir=/usr/share/man \
			--sbindir=/usr/sbin \
			--sysconfdir=/etc \
			$(DISABLE_NLS) \
			--enable-shared \
			--enable-static \
			--disable-integer-datetimes \
			--disable-rpath \
			--without-bonjour \
			--without-gssapi \
			--without-ldap \
			--without-openssl \
			--without-pam \
			--without-perl \
			--without-python \
			--without-readline \
			--without-tcl \
			--with-zlib="yes" \
			--enable-depend \
			--with-system-timezone=/tmp \
	);
	$(MAKE) -C $(PKG_BUILD_DIR)/src/interfaces/ecpg/preproc CC="$(HOSTCC)" CFLAGS+="-I../../libpq"
	mv $(PKG_BUILD_DIR)/src/interfaces/ecpg/preproc/ecpg \
		$(PKG_BUILD_DIR)/src/interfaces/ecpg/preproc/ecpg.host
	$(MAKE) -C $(PKG_BUILD_DIR)/src/timezone CC="$(HOSTCC)"
	mv $(PKG_BUILD_DIR)/src/timezone/zic $(PKG_BUILD_DIR)/host-zic
	$(INSTALL_DIR) $(STAGING_DIR)/host/bin/
	$(CP) $(PKG_BUILD_DIR)/host-zic $(STAGING_DIR)/host/bin/zic
	$(MAKE) -C $(PKG_BUILD_DIR)/src/bin/pg_config CC="$(HOSTCC)"
	mv $(PKG_BUILD_DIR)/src/bin/pg_config/pg_config \
		$(PKG_BUILD_DIR)/src/bin/pg_config/pg_config.host
	$(MAKE) -C $(PKG_BUILD_DIR) distclean

	(cd $(PKG_BUILD_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="$$$$CPPFLAGS $(TARGET_CPPFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--target=$(GNU_TARGET_NAME) \
			--host=$(GNU_TARGET_NAME) \
			--build=$(GNU_HOST_NAME) \
			--program-prefix="" \
			--program-suffix="" \
			--prefix=/usr \
			--exec-prefix=/usr \
			--bindir=/usr/bin \
			--datadir=/usr/share \
			--includedir=/usr/include \
			--infodir=/usr/share/info \
			--libdir=/usr/lib \
			--libexecdir=/usr/lib \
			--localstatedir=/var \
			--mandir=/usr/share/man \
			--sbindir=/usr/sbin \
			--sysconfdir=/etc \
			$(DISABLE_NLS) \
			$(DISABLE_LARGEFILE) \
			--enable-shared \
			--enable-static \
			--disable-integer-datetimes \
			--disable-rpath \
			--without-bonjour \
			--without-gssapi \
			--without-ldap \
			--without-openssl \
			--without-pam \
			--without-perl \
			--without-python \
			--without-tcl \
			--with-zlib="yes" \
			--enable-depend \
			$(if $(CONFIG_TARGET_avr32),--disable-spinlocks) \
	);
	$(SED) 's@ECPG = ../../preproc/ecpg@ECPG = ../../preproc/ecpg.host@' $(PKG_BUILD_DIR)/src/interfaces/ecpg/test/Makefile.regress
endef

TARGET_CFLAGS += $(FPIC) -lpthread

# because PROFILE means something else in the project Makefile
unexport PROFILE

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C "$(PKG_BUILD_DIR)" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all
	+$(MAKE) $(PKG_JOBS) -C "$(PKG_BUILD_DIR)" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		install
endef

define Package/libpq/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpq.so.* $(1)/usr/lib/
endef

define Package/pgsql-cli/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/psql $(1)/usr/bin/
endef

define Package/pgsql-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/share/postgresql
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin
	ln -sf postgres $(1)/usr/bin/postmaster

	$(INSTALL_BIN) ./files/postgresql.init $(1)/etc/init.d/postgresql

	$(CP) -r $(PKG_INSTALL_DIR)/usr/share/postgresql/* \
		$(1)/usr/share/postgresql

	$(INSTALL_DATA) ./files/postgresql.config $(1)/etc/config/postgresql

	$(CP) -r \
		$(PKG_INSTALL_DIR)/usr/lib/postgresql \
		$(1)/usr/lib
endef

define Package/pgsql-server/conffiles
/etc/config/postgresql
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/bin/pg_config/pg_config.host $(1)/usr/bin/pg_config
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libpq $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libpq-fe.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/pg_config.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/pg_config_manual.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/postgres_ext.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/pg_config_ext.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/postgresql $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpq.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/src/interfaces/ecpg/preproc/ecpg.host $(1)/usr/bin/ecpg
	$(CP) $(PKG_BUILD_DIR)/host-zic $(1)/usr/bin/zic
endef

$(eval $(call BuildPackage,libpq))
$(eval $(call BuildPackage,pgsql-cli))
$(eval $(call BuildPackage,pgsql-server))
