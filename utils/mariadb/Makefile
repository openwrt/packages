#
# Copyright (C) 2018 Sebastian Kemper <sebastian_ml@gmx.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mariadb
PKG_VERSION:=10.2.26
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL := \
	https://mirror.netcologne.de/mariadb/$(PKG_NAME)-$(PKG_VERSION)/source \
	https://mirror.lstn.net/mariadb/$(PKG_NAME)-$(PKG_VERSION)/source \
	https://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/$(PKG_NAME)-$(PKG_VERSION)/source \
	https://downloads.mariadb.org/interstitial/$(PKG_NAME)-$(PKG_VERSION)/source

PKG_HASH:=152fe941c4f2a352b2b3a4db1ef64e70235fd9ff055af62ad7bda9f2b2191528
PKG_MAINTAINER:=Sebastian Kemper <sebastian_ml@gmx.net>
PKG_LICENSE:=GPL-2.0 LGPL-2.1
PKG_LICENSE_FILES:=COPYING THIRDPARTY libmariadb/COPYING.LIB

PKG_CPE_ID:=cpe:/a:mariadb:mariadb

HOST_BUILD_PARALLEL:=1
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

HOST_BUILD_DEPENDS:=libxml2/host
# Without libevent2 tests/async_queries sporadically fails on the bots
PKG_BUILD_DEPENDS:=libevent2 mariadb/host

CMAKE_INSTALL:=1

CONF_DIR:=/etc/mysql
PLUGIN_DIR:=/usr/lib/mariadb/plugin
SHARE_DIR:=/usr/share/mariadb

MARIADB_DISABLE_ENGINES := \
	cassandra \
	example \
	mroonga \
	oqgraph \
	rocksdb \
	test_sql_discovery \
	tokudb

MARIADB_DISABLE_PLUGINS := \
	audit_null \
	auth_examples \
	aws_key_management \
	cracklib_password_check \
	daemon_example \
	debug_key_management \
	example_key_management \
	fulltext

MARIADB_LIB_PLUGINS := \
	auth_gssapi_client

MARIADB_SERVER_PLUGINS := \
	auth_ed25519 \
	auth_gssapi \
	auth_pam \
	disks \
	feedback \
	file_key_management \
	ha_archive \
	ha_blackhole \
	ha_connect \
	ha_federated \
	ha_federatedx \
	ha_sphinx \
	ha_spider \
	handlersocket \
	locales \
	metadata_lock_info \
	query_cache_info \
	query_response_time \
	semisync_master \
	semisync_slave \
	server_audit \
	simple_password_check \
	sql_errlog \
	wsrep_info

PKG_CONFIG_DEPENDS := \
	$(patsubst %,CONFIG_PACKAGE_lib$(PKG_NAME)-plugin-%,$(subst _,-,$(MARIADB_LIB_PLUGINS))) \
	$(patsubst %,CONFIG_PACKAGE_$(PKG_NAME)-server-plugin-%,$(subst _,-,$(MARIADB_SERVER_PLUGINS))) \
	CONFIG_PACKAGE_mariadb-server

plugin-auth_gssapi_client       := PLUGIN_AUTH_GSSAPI_CLIENT

plugin-auth_ed25519             := PLUGIN_AUTH_ED25519
plugin-auth_gssapi              := PLUGIN_AUTH_GSSAPI
plugin-auth_pam                 := PLUGIN_AUTH_PAM
plugin-disks                    := PLUGIN_DISKS
plugin-feedback                 := PLUGIN_FEEDBACK
plugin-file_key_management      := PLUGIN_FILE_KEY_MANAGEMENT
plugin-ha_archive               := PLUGIN_ARCHIVE
plugin-ha_blackhole             := PLUGIN_BLACKHOLE
plugin-ha_connect               := PLUGIN_CONNECT
plugin-ha_federated             := PLUGIN_FEDERATED
plugin-ha_federatedx            := PLUGIN_FEDERATEDX
plugin-ha_sphinx                := PLUGIN_SPHINX
plugin-ha_spider                := PLUGIN_SPIDER
plugin-handlersocket            := PLUGIN_HANDLERSOCKET
plugin-locales                  := PLUGIN_LOCALES
plugin-metadata_lock_info       := PLUGIN_METADATA_LOCK_INFO
plugin-query_cache_info         := PLUGIN_QUERY_CACHE_INFO
plugin-query_response_time      := PLUGIN_QUERY_RESPONSE_TIME
plugin-semisync_master          := PLUGIN_SEMISYNC_MASTER
plugin-semisync_slave           := PLUGIN_SEMISYNC_SLAVE
plugin-server_audit             := PLUGIN_SERVER_AUDIT
plugin-simple_password_check    := PLUGIN_SIMPLE_PASSWORD_CHECK
plugin-sql_errlog               := PLUGIN_SQL_ERRLOG
plugin-wsrep_info               := PLUGIN_WSREP_INFO

MARIADB_CLIENT := \
	mysql \
	mysqlcheck

MARIADB_CLIENT_EXTRA := \
	mysql_find_rows \
	mysql_waitpid \
	mysqlaccess \
	mysqladmin \
	mysqldump \
	mysqlimport \
	mysqlshow \
	mysqlslap \
	mytop

MARIADB_SERVER := \
	innochecksum \
	my_print_defaults \
	mysql_install_db \
	mysql_upgrade \
	mysqld

MARIADB_SERVER_EXTRA := \
	aria* \
	mariabackup \
	msql2mysql \
	myisam_ftdump \
	myisamchk \
	myisamlog \
	myisampack \
	mysql_convert_table_format \
	mysql_fix_extensions \
	mysql_plugin \
	mysql_secure_installation \
	mysql_setpermission \
	mysql_tzinfo_to_sql \
	mysqlbinlog \
	mysqld_multi \
	mysqldumpslow \
	mysqlhotcopy \
	perror \
	replace \
	resolve_stack_dump \
	wsrep_sst_*

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/nls.mk

MARIADB_COMMON_DEPENDS := \
	$(ICONV_DEPENDS) \
	+libopenssl \
	+zlib

MARIADB_COMMON_DEPENDS_EXE := \
	$(MARIADB_COMMON_DEPENDS) \
	+libatomic \
	+libstdcpp

# Pass CPPFLAGS in the CFLAGS as otherwise the build system will
# ignore them.
TARGET_CFLAGS+=$(TARGET_CPPFLAGS)

define Package/mariadb/disable/engine
	echo > $(1)/storage/$(2)/CMakeLists.txt
endef

define Package/mariadb/disable/plugin
	echo > $(1)/plugin/$(2)/CMakeLists.txt
endef

define Package/mariadb/install/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(2) $(1)/usr/bin
endef

define Package/mariadb/install/plugin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)$(PLUGIN_DIR)/$(2).so $(1)$(PLUGIN_DIR)
endef

define Package/mariadb/description/Default
MariaDB is a very fast and robust SQL database server.
endef

define Package/libmariadb/Default
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=https://mariadb.org/
endef

define Package/libmariadb
  $(call Package/libmariadb/Default)
  DEPENDS:=+mariadb-common \
	  $(MARIADB_COMMON_DEPENDS)
  TITLE:=MariaDB database client library
  MENU:=1
  PROVIDES:=libmariadbclient libmysqlclient libmysqlclient-r
endef

define Package/libmariadb/conffiles
$(CONF_DIR)/conf.d/50-client.cnf
endef

define Package/libmariadb/description
$(call Package/mariadb/description/Default)

This package includes the client library.

endef

define Package/mariadb/Default
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://mariadb.org/
  SUBMENU:=Database
endef

define Package/mariadb-client
  $(call Package/mariadb/Default)
  TITLE:=MariaDB database client
  MENU:=1
  DEPENDS:=mariadb-client-base
endef

define Package/mariadb-client/description
$(call Package/mariadb/description/Default)

This package includes the following core client binaries:

$(subst $(space),$(newline),$(MARIADB_CLIENT))

endef

define Package/mariadb-client-base
  $(call Package/mariadb/Default)
  TITLE:=MariaDB database client base
  DEPENDS:=mariadb-common \
	  $(MARIADB_COMMON_DEPENDS_EXE) \
	  +libedit
endef

define Package/mariadb-client-base/conffiles
$(CONF_DIR)/conf.d/50-mysql-clients.cnf
endef

define Package/mariadb-client-base/description
$(call Package/mariadb/description/Default)

This package provides the foundation for mariadb-client. It installs the
configuration and the dependencies.

endef

define Package/mariadb-client-extra
  $(call Package/mariadb/Default)
  TITLE:=MariaDB database client extra
  DEPENDS:=mariadb-client
endef

define Package/mariadb-client-extra/description
$(call Package/mariadb/description/Default)

This package includes the following extra client binaries:

$(subst $(space),$(newline),$(MARIADB_CLIENT_EXTRA))

endef

define Package/mariadb-common
  $(call Package/mariadb/Default)
  TITLE:=MariaDB database common files
  DEPENDS:=
endef

define Package/mariadb-common/conffiles
$(CONF_DIR)/my.cnf
endef

define Package/mariadb-common/description
$(call Package/mariadb/description/Default)

This package includes shared files, for example $(CONF_DIR)/my.cnf.

endef

define Package/mariadb-server
  $(call Package/mariadb/Default)
  DEPENDS:=mariadb-server-base
  TITLE:=MariaDB database server
  MENU:=1
  PROVIDES:=mysql-server
endef

define Package/mariadb-server/description
$(call Package/mariadb/description/Default)

This package includes the following core server binaries:

$(subst $(space),$(newline),$(MARIADB_SERVER))

endef

define Package/mariadb-server-base
  $(call Package/mariadb/Default)
  DEPENDS:=mariadb-common \
	  $(MARIADB_COMMON_DEPENDS_EXE) \
	  +libaio \
	  +liblzma \
	  +libpcre \
	  +resolveip
  TITLE:=MariaDB database server base
  USERID:=mariadb=376:mariadb=376
endef

define Package/mariadb-server-base/conffiles
$(CONF_DIR)/conf.d/50-server.cnf
$(CONF_DIR)/conf.d/60-galera.cnf
/etc/config/mysqld
endef

define Package/mariadb-server-base/description
$(call Package/mariadb/description/Default)

This package provides the foundation for mariadb-server. It installs the
init script, support files (configuration etc.), the user "mariadb" and
the dependencies.

endef

define Package/mariadb-server-extra
  $(call Package/mariadb/Default)
  TITLE:=MariaDB database server extra
  DEPENDS:=mariadb-server
endef

define Package/mariadb-server-extra/description
$(call Package/mariadb/description/Default)

This package includes the following extra server binaries:

$(subst $(space),$(newline),$(MARIADB_SERVER_EXTRA))

endef

# We won't need unit tests
CMAKE_OPTIONS += -DWITH_UNIT_TESTS=0

# This value is determined automatically during straight compile by compiling
# and running a test code. You cannot do that during cross-compile. However the
# stack grows downward in most if not all modern systems. The only exception
# according to buildroot is PA-RISC which is not supported by OpenWrt as far as
# I know. Therefore it makes sense to hardcode the value. If an arch is added
# the stack of which grows up one should expect unpredictable behavior at run
# time.
CMAKE_OPTIONS += -DSTACK_DIRECTION=-1

# Make it explicit that we are cross-compiling
CMAKE_OPTIONS += -DCMAKE_CROSSCOMPILING=1

# Explicitly disable dtrace to avoid detection of a host version
CMAKE_OPTIONS += -DENABLE_DTRACE=0

# Prevent MariaDB from messing with OpenWrt's C(XX)FLAGS
CMAKE_OPTIONS += -DSECURITY_HARDENED=OFF

ifeq ($(CONFIG_PACKAGE_mariadb-server),)
CMAKE_OPTIONS += -DWITHOUT_SERVER=ON
else
# Enable the auth_socket plugin and let unix user root access MariaDB without a
# separate password.
CMAKE_OPTIONS += -DWITHOUT_SERVER=OFF -DPLUGIN_AUTH_SOCKET=STATIC
endif

CMAKE_OPTIONS += \
	-DCONNECT_WITH_JDBC=NO \
	-DCONNECT_WITH_LIBXML2=system \
	-DCONNECT_WITH_MONGO=NO \
	-DCONNECT_WITH_ODBC=NO \
	-DDISABLE_SHARED=NO \
	-DENABLED_PROFILING=OFF \
	-DENABLE_STATIC_LIBS=OFF \
	-DINSTALL_DOCDIR=share/doc/mariadb \
	-DINSTALL_DOCREADMEDIR=share/doc/mariadb \
	-DINSTALL_INFODIR=share/info \
	-DINSTALL_MANDIR=share/man \
	-DINSTALL_MYSQLSHAREDIR=share/mariadb \
	-DINSTALL_MYSQLTESTDIR="" \
	-DINSTALL_PLUGINDIR=lib/mariadb/plugin \
	-DINSTALL_SBINDIR=bin \
	-DINSTALL_SCRIPTDIR=bin \
	-DINSTALL_SQLBENCHDIR="" \
	-DINSTALL_SUPPORTFILESDIR=share/mariadb \
	-DINSTALL_UNIX_ADDRDIR=/var/run/mysqld/mysqld.sock \
	-DMYSQL_DATADIR=/var/lib/mysql \
	-DMYSQL_UNIX_ADDR=/var/run/mysqld/mysqld.sock \
	-DSKIP_TESTS=ON \
	-DWITH_DEBUG=OFF \
	-DWITH_EMBEDDED_SERVER=OFF \
	-DWITH_INNODB_BZIP2=OFF \
	-DWITH_INNODB_LZ4=OFF \
	-DWITH_INNODB_LZMA=ON \
	-DWITH_INNODB_LZO=OFF \
	-DWITH_INNODB_SNAPPY=OFF \
	-DWITH_JEMALLOC=OFF \
	-DWITH_LIBARCHIVE=OFF \
	-DWITH_LIBWRAP=OFF \
	-DWITH_MARIABACKUP=ON \
	-DWITH_PCRE=system \
	-DWITH_SAFEMALLOC=OFF \
	-DWITH_SSL=system \
	-DWITH_SYSTEMD=no \
	-DWITH_VALGRIND=OFF \
	-DWITH_ZLIB=system

# Help MariaDB find the correct libiconv.
# nls.mk sets it up so that with CONFIG_BUILD_NLS libiconv-full would be used,
# otherwise libiconv-stub (independent of the selected libc). MariaDB needs a
# leg up to find/pick the right lib.
CMAKE_OPTIONS += \
	-DICONV_INCLUDE_DIR=$(ICONV_PREFIX)/include \
	-DICONV_LIBRARIES=$(ICONV_PREFIX)/lib/libiconv.$(if $(CONFIG_BUILD_NLS),so,a)

CMAKE_OPTIONS += \
	$(foreach p,$(MARIADB_LIB_PLUGINS),-D$(plugin-$(p))=$(if $(CONFIG_PACKAGE_lib$(PKG_NAME)-plugin-$(subst _,-,$(p))),DYNAMIC,OFF)) \
	$(foreach p,$(MARIADB_SERVER_PLUGINS),-D$(plugin-$(p))=$(if $(CONFIG_PACKAGE_$(PKG_NAME)-server-plugin-$(subst _,-,$(p))),DYNAMIC,NO))

# Set CMAKE_FIND_ROOT_PATH_MODE_INCLUDE and CMAKE_FIND_ROOT_PATH_MODE_LIBRARY
# to BOTH as otherwise the host build will not find some required dependencies
# installed on the host machine, like ncurses.
#
# Add "$(STAGING_DIR_HOSTPKG)/lib" to the RPATH of the host helpers,
# otherwise they might not find the location of a library at run time.
CMAKE_HOST_OPTIONS += \
	-DCMAKE_BUILD_WITH_INSTALL_RPATH=TRUE \
	-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH \
	-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH \
	-DCMAKE_INSTALL_RPATH="$(STAGING_DIR_HOSTPKG)/lib" \
	-DCMAKE_SKIP_RPATH=FALSE \
	-DWITHOUT_SERVER=OFF

# Some helpers must be compiled for host in order to crosscompile MariaDB for
# the target. They are then included by import_executables.cmake which is
# generated during the build of the host helpers. It is not necessary to build
# the whole host package, only the "import_executables" target.
# -DIMPORT_EXECUTABLES=$(HOST_BUILD_DIR)/import_executables.cmake
# must then be passed to cmake during target build.
# See also https://mariadb.com/kb/en/mariadb/cross-compiling-mariadb/

CMAKE_OPTIONS += -DIMPORT_EXECUTABLES=$(STAGING_DIR_HOSTPKG)/share/mariadb/import_executables.cmake

# Disable some engines/plugins here as well - decreases the number of cmake checks.
define Host/Prepare
	$(call Host/Prepare/Default)
	$(foreach e,$(MARIADB_DISABLE_ENGINES),$(call Package/mariadb/disable/engine,$(HOST_BUILD_DIR),$(e));)
	$(foreach p,$(MARIADB_DISABLE_PLUGINS),$(call Package/mariadb/disable/plugin,$(HOST_BUILD_DIR),$(p));)
endef

define Host/Compile
	$(call Host/Compile/Default,import_executables)
endef

define Host/Install
	$(SED) 's|$(HOST_BUILD_DIR)|$(STAGING_DIR_HOSTPKG)/share/mariadb|' $(HOST_BUILD_DIR)/import_executables.cmake
	$(INSTALL_DIR) $(1)/share/mariadb/{dbug,extra,scripts,sql}
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/dbug/factorial $(1)/share/mariadb/dbug
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/extra/comp_err $(1)/share/mariadb/extra
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/scripts/comp_sql $(1)/share/mariadb/scripts
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/sql/{gen_lex_hash,gen_lex_token} $(1)/share/mariadb/sql
	$(INSTALL_DATA) $(HOST_BUILD_DIR)/import_executables.cmake $(1)/share/mariadb
endef

# LIBICONV_PLUG is used in GNU's libiconv for redefinition of exports [e.g.
# from libiconv_open() to iconv_open()]. But in OpenWrt this variable is not set
# when building libiconv-full. So when MariaDB sets LIBICONV_PLUG it expects
# iconv_open() to be available for example, which is not the case - only
# libiconv_open() is. To address this prevent the variable from being set.
# libiconv-stub does not use this variable, so there is no harm in always doing
# this.

define Build/Prepare
	$(call Build/Prepare/Default)
	$(SED) '/ADD_DEFINITIONS(-DLIBICONV_PLUG)/d' $(PKG_BUILD_DIR)/libmariadb/libmariadb/CMakeLists.txt
	$(foreach e,$(MARIADB_DISABLE_ENGINES),$(call Package/mariadb/disable/engine,$(PKG_BUILD_DIR),$(e));)
	$(foreach p,$(MARIADB_DISABLE_PLUGINS),$(call Package/mariadb/disable/plugin,$(PKG_BUILD_DIR),$(p));)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin $(1)/usr/bin $(1)/usr/include $(1)/usr/lib/mysql $(1)/usr/lib/pkgconfig $(1)/usr/share/aclocal
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mysql_config $(1)/usr/bin
	$(LN) $(STAGING_DIR)/usr/bin/mysql_config $(2)/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/include/mysql $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{mariadb,mysqlclient}*.so* $(1)/usr/lib
	cd $(1)/usr/lib/mysql; $(LN) ../lib{mariadb,mysqlclient}*.so* .
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libmariadb.pc $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/aclocal/mysql.m4 $(1)/usr/share/aclocal
endef

define Package/libmariadb/install
	$(INSTALL_DIR) $(1)$(CONF_DIR)/conf.d
	$(INSTALL_DIR) $(1)$(PLUGIN_DIR)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{mariadb,mysqlclient}*.so* $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)$(PLUGIN_DIR)/caching_sha2_password.so $(1)$(PLUGIN_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)$(PLUGIN_DIR)/client_ed25519.so $(1)$(PLUGIN_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)$(PLUGIN_DIR)/dialog.so $(1)$(PLUGIN_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)$(PLUGIN_DIR)/mysql_clear_password.so $(1)$(PLUGIN_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)$(PLUGIN_DIR)/sha256_password.so $(1)$(PLUGIN_DIR)
	$(INSTALL_CONF) conf/50-client.cnf $(1)$(CONF_DIR)/conf.d
endef

define Package/mariadb-client/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(foreach b,$(MARIADB_CLIENT),$(call Package/mariadb/install/bin,$(1),$(b));)
	# Install convenience links for mysqlcheck multi-call binary
	cd $(1)/usr/bin; $(LN) mysqlcheck mysqlanalyze
	cd $(1)/usr/bin; $(LN) mysqlcheck mysqlrepair
	cd $(1)/usr/bin; $(LN) mysqlcheck mysqloptimize
endef

define Package/mariadb-client-base/install
	$(INSTALL_DIR) $(1)$(CONF_DIR)/conf.d
	$(INSTALL_CONF) conf/50-mysql-clients.cnf $(1)$(CONF_DIR)/conf.d
endef

define Package/mariadb-client-extra/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(foreach b,$(MARIADB_CLIENT_EXTRA),$(call Package/mariadb/install/bin,$(1),$(b));)
endef

define Package/mariadb-common/install
	$(INSTALL_DIR) $(1)$(CONF_DIR)
	$(INSTALL_CONF) conf/my.cnf $(1)$(CONF_DIR)
endef

define Package/mariadb-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(foreach b,$(MARIADB_SERVER),$(call Package/mariadb/install/bin,$(1),$(b));)
endef

define Package/mariadb-server-base/install
	$(INSTALL_DIR) $(1)$(CONF_DIR)/conf.d
	$(INSTALL_DIR) $(1)$(SHARE_DIR)/charsets
	$(INSTALL_DIR) $(1)$(SHARE_DIR)/english
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/mysqld.init $(1)/etc/init.d/mysqld
	$(SED) '/^[a-z]/s/^/#/' $(PKG_INSTALL_DIR)$(SHARE_DIR)/wsrep.cnf
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)$(SHARE_DIR)/wsrep.cnf $(1)$(CONF_DIR)/conf.d/60-galera.cnf
	$(INSTALL_CONF) conf/50-server.cnf $(1)$(CONF_DIR)/conf.d
	$(INSTALL_CONF) files/mysqld.config $(1)/etc/config/mysqld
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)$(SHARE_DIR)/charsets/* $(1)$(SHARE_DIR)/charsets
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)$(SHARE_DIR)/english/errmsg.sys $(1)$(SHARE_DIR)/english
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)$(SHARE_DIR)/fill_help_tables.sql $(1)$(SHARE_DIR)
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)$(SHARE_DIR)/maria_add_gis_sp_bootstrap.sql $(1)$(SHARE_DIR)
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)$(SHARE_DIR)/mysql_performance_tables.sql $(1)$(SHARE_DIR)
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)$(SHARE_DIR)/mysql_system_tables.sql $(1)$(SHARE_DIR)
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)$(SHARE_DIR)/mysql_system_tables_data.sql $(1)$(SHARE_DIR)
endef

define Package/mariadb-server-extra/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(SED) 's,/bin/bash,/bin/sh,g' $(PKG_INSTALL_DIR)/usr/bin/wsrep_sst_*
	$(foreach b,$(MARIADB_SERVER_EXTRA),$(call Package/mariadb/install/bin,$(1),$(b));)
endef

define BuildPlugin
  define Package/$(1)-plugin-$(subst _,-,$(2))
    $(call Package/$(subst mariadb-server,mariadb,$(1))/Default)
    TITLE:=$(1) plugin
    DEPENDS:=$(1) $(patsubst +%,+PACKAGE_$(1)-plugin-$(subst _,-,$(2)):%,$(3))
  endef
  define Package/$(1)-plugin-$(subst _,-,$(2))/description
    $(call Package/mariadb/description/Default)

This package provides the $(2) plugin.

  endef
  define Package/$(1)-plugin-$(subst _,-,$(2))/install
	  $(INSTALL_DIR) $$(1)$(PLUGIN_DIR)
	  $(call Package/mariadb/install/plugin,$$(1),$(2))
  endef
  $$(eval $$(call BuildPackage,$(1)-plugin-$(subst _,-,$(2))))
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libmariadb))
$(eval $(call BuildPackage,mariadb-client))
$(eval $(call BuildPackage,mariadb-client-base))
$(eval $(call BuildPackage,mariadb-client-extra))
$(eval $(call BuildPackage,mariadb-common))
$(eval $(call BuildPackage,mariadb-server))
$(eval $(call BuildPackage,mariadb-server-base))
$(eval $(call BuildPackage,mariadb-server-extra))

$(eval $(call BuildPlugin,libmariadb,auth_gssapi_client,+krb5-libs))
$(eval $(call BuildPlugin,mariadb-server,auth_ed25519,))
$(eval $(call BuildPlugin,mariadb-server,auth_gssapi,+krb5-libs))
$(eval $(call BuildPlugin,mariadb-server,auth_pam,+libpam))
$(eval $(call BuildPlugin,mariadb-server,disks,))
$(eval $(call BuildPlugin,mariadb-server,feedback,))
$(eval $(call BuildPlugin,mariadb-server,file_key_management,))
$(eval $(call BuildPlugin,mariadb-server,ha_archive,))
$(eval $(call BuildPlugin,mariadb-server,ha_blackhole,))
$(eval $(call BuildPlugin,mariadb-server,ha_connect,+libxml2))
$(eval $(call BuildPlugin,mariadb-server,ha_federated,))
$(eval $(call BuildPlugin,mariadb-server,ha_federatedx,))
$(eval $(call BuildPlugin,mariadb-server,ha_sphinx,))
$(eval $(call BuildPlugin,mariadb-server,ha_spider,))
$(eval $(call BuildPlugin,mariadb-server,handlersocket,))
$(eval $(call BuildPlugin,mariadb-server,locales,))
$(eval $(call BuildPlugin,mariadb-server,metadata_lock_info,))
$(eval $(call BuildPlugin,mariadb-server,query_cache_info,))
$(eval $(call BuildPlugin,mariadb-server,query_response_time,))
$(eval $(call BuildPlugin,mariadb-server,semisync_master,))
$(eval $(call BuildPlugin,mariadb-server,semisync_slave,))
$(eval $(call BuildPlugin,mariadb-server,server_audit,))
$(eval $(call BuildPlugin,mariadb-server,simple_password_check,))
$(eval $(call BuildPlugin,mariadb-server,sql_errlog,))
$(eval $(call BuildPlugin,mariadb-server,wsrep_info,))

