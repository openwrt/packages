#
# Copyright (C) 2006-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=postgresql
PKG_VERSION:=9.5.14
PKG_RELEASE:=1
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=PostgreSQL

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=\
	https://ftp.postgresql.org/pub/source/v$(PKG_VERSION) \
	http://ftp.postgresql.org/pub/source/v$(PKG_VERSION) \
	ftp://ftp.postgresql.org/pub/source/v$(PKG_VERSION)
PKG_MD5SUM:=3e2cd5ea0117431f72c9917c1bbad578ea68732cb284d1691f37356ca0301a4d
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_FIXUP:=autoreconf
PKG_MACRO_PATHS:=config
PKG_BUILD_DEPENDS += postgresql/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/libpq
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+zlib +libreadline +libpthread +libncursesw
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
  DEPENDS:=+libpq +librt
  TITLE:=Command Line Interface (CLI) to PostgreSQL databases
  URL:=http://www.postgresql.org/
  SUBMENU:=database
endef

define Package/pgsql-cli/description
Command Line Interface (CLI) to PostgreSQL databases.
endef

define Package/pgsql-cli-extra
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libpq +librt
  TITLE:=Command Line extras for PostgreSQL databases
  URL:=http://www.postgresql.org/
  SUBMENU:=database
endef

define Package/pgsql-cli-extra/description
Command Line extras for PostgreSQL databases.
endef

define Package/pgsql-server
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libpq +librt +pgsql-cli
  TITLE:=PostgreSQL databases Server
  URL:=http://www.postgresql.org/
  SUBMENU:=database
  USERID:=postgres=5432:postgres=5432
endef

define Package/pgsql-server/description
PostgreSQL databases Server.
endef

PGSQL_CLI_EXTRA_BIN := \
	clusterdb	\
	createdb	\
	createlang	\
	createuser	\
	dropdb		\
	droplang	\
	dropuser	\
	pgbench		\
	reindexdb	\
	vacuumdb

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

HOST_CONFIGURE_ARGS += \
			$(DISABLE_NLS) \
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
			--enable-depend

CONFIGURE_ARGS += \
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
			$(if $(CONFIG_TARGET_avr32),--disable-spinlocks)

# Need a native ecpg ,pg_config, and zic for build
define Host/Compile
	$(MAKE) -C $(HOST_BUILD_DIR)/src/interfaces/ecpg/preproc CC="$(HOSTCC)"
	$(MAKE) -C $(HOST_BUILD_DIR)/src/timezone CC="$(HOSTCC)"
	$(MAKE) -C $(HOST_BUILD_DIR)/src/bin/pg_config CC="$(HOSTCC)"
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR)/usr/bin/
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/src/bin/pg_config/pg_config $(STAGING_DIR)/usr/bin/
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/bin/
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/src/interfaces/ecpg/preproc/ecpg $(STAGING_DIR_HOSTPKG)/bin/
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/src/timezone/zic $(STAGING_DIR_HOSTPKG)/bin/
endef

define Build/Configure
	$(Build/Configure/Default)
	$(SED) 's@ECPG = ../../preproc/ecpg@ECPG = $(STAGING_DIR_HOSTPKG)/bin/ecpg@' $(PKG_BUILD_DIR)/src/interfaces/ecpg/test/Makefile.regress
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

define Package/pgsql-cli-extra/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(foreach bin,$(PGSQL_CLI_EXTRA_BIN),$(PKG_INSTALL_DIR)/usr/bin/$(bin)) $(1)/usr/bin/
endef

define Package/pgsql-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pg_* $(PKG_INSTALL_DIR)/usr/bin/postgres \
			$(PKG_INSTALL_DIR)/usr/bin/initdb $(1)/usr/bin/
	ln -sf postgres $(1)/usr/bin/postmaster

	$(INSTALL_DIR) $(1)/usr/share/postgresql
	$(CP) $(PKG_INSTALL_DIR)/usr/share/postgresql/* \
		$(1)/usr/share/postgresql

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/postgresql \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/lib/functions
	$(INSTALL_BIN) ./files/postgresql.sh $(1)/lib/functions/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/postgresql.config $(1)/etc/config/postgresql

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/postgresql.init $(1)/etc/init.d/postgresql
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin
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
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libpq))
$(eval $(call BuildPackage,pgsql-cli))
$(eval $(call BuildPackage,pgsql-cli-extra))
$(eval $(call BuildPackage,pgsql-server))
