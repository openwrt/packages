#
# Copyright (C) 2018 Sebastian Kemper <sebastian_ml@gmx.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mariadb
PKG_VERSION:=10.1.38
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL := \
	https://mirror.netcologne.de/mariadb/$(PKG_NAME)-$(PKG_VERSION)/source \
	https://mirror.lstn.net/mariadb/$(PKG_NAME)-$(PKG_VERSION)/source \
	https://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/$(PKG_NAME)-$(PKG_VERSION)/source \
	https://downloads.mariadb.org/interstitial/$(PKG_NAME)-$(PKG_VERSION)/source

PKG_HASH:=caf1f4fc237d143343995b6625375aef911dfc366433645d400727e7063f077f
PKG_MAINTAINER:=Sebastian Kemper <sebastian_ml@gmx.net>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

HOST_BUILD_PARALLEL:=1
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

HOST_BUILD_DEPENDS:=libxml2/host
# Without libevent2 tests/async_queries sporadically fails on the bots
PKG_BUILD_DEPENDS:=libevent2 mariadb/host

CMAKE_INSTALL:=1

PLUGIN_DIR:=/usr/lib/mysql/plugin

MARIADB_COMMON_DEPENDS := \
	+libatomic \
	+libopenssl \
	+libstdcpp \
	+zlib

MARIADB_SERVER_PLUGINS := \
	adt_null \
	auth_0x0100 \
	auth_ed25519 \
	auth_socket \
	auth_test_plugin \
	client_ed25519 \
	debug_key_management \
	dialog_examples \
	disks \
	example_key_management \
	feedback \
	file_key_management \
	ha_archive \
	ha_blackhole \
	ha_connect \
	ha_example \
	ha_federated \
	ha_federatedx \
	ha_innodb \
	ha_sequence \
	ha_sphinx \
	ha_spider \
	ha_test_sql_discovery \
	handlersocket \
	libdaemon_example \
	locales \
	metadata_lock_info \
	mypluglib \
	qa_auth_client \
	qa_auth_interface \
	qa_auth_server \
	query_cache_info \
	query_response_time \
	semisync_master \
	semisync_slave \
	server_audit \
	simple_password_check \
	sql_errlog \
	wsrep_info

PKG_CONFIG_DEPENDS := \
	$(patsubst %,CONFIG_PACKAGE_$(PKG_NAME)-server-plugin-%,$(subst _,-,$(MARIADB_SERVER_PLUGINS))) \
	CONFIG_PACKAGE_mariadb-server

plugin-adt_null                 := PLUGIN_AUDIT_NULL
plugin-auth_0x0100              := PLUGIN_AUTH_0X0100
plugin-auth_ed25519             := PLUGIN_AUTH_ED25519
plugin-auth_socket              := PLUGIN_AUTH_SOCKET
plugin-auth_test_plugin         := PLUGIN_AUTH_TEST_PLUGIN
plugin-client_ed25519           := PLUGIN_CLIENT_ED25519
plugin-debug_key_management     := PLUGIN_DEBUG_KEY_MANAGEMENT
plugin-dialog_examples          := PLUGIN_DIALOG_EXAMPLES
plugin-disks                    := PLUGIN_DISKS
plugin-example_key_management   := PLUGIN_EXAMPLE_KEY_MANAGEMENT
plugin-feedback                 := PLUGIN_FEEDBACK
plugin-file_key_management      := PLUGIN_FILE_KEY_MANAGEMENT
plugin-ha_archive               := PLUGIN_ARCHIVE
plugin-ha_blackhole             := PLUGIN_BLACKHOLE
plugin-ha_connect               := PLUGIN_CONNECT
plugin-ha_example               := PLUGIN_EXAMPLE
plugin-ha_federated             := PLUGIN_FEDERATED
plugin-ha_federatedx            := PLUGIN_FEDERATEDX
plugin-ha_innodb                := PLUGIN_INNOBASE
plugin-ha_sequence              := PLUGIN_SEQUENCE
plugin-ha_sphinx                := PLUGIN_SPHINX
plugin-ha_spider                := PLUGIN_SPIDER
plugin-ha_test_sql_discovery    := PLUGIN_TEST_SQL_DISCOVERY
plugin-handlersocket            := PLUGIN_HANDLERSOCKET
plugin-libdaemon_example        := PLUGIN_DAEMON_EXAMPLE
plugin-locales                  := PLUGIN_LOCALES
plugin-metadata_lock_info       := PLUGIN_METADATA_LOCK_INFO
plugin-mypluglib                := PLUGIN_FTEXAMPLE
plugin-qa_auth_client           := PLUGIN_QA_AUTH_CLIENT
plugin-qa_auth_interface        := PLUGIN_QA_AUTH_INTERFACE
plugin-qa_auth_server           := PLUGIN_QA_AUTH_SERVER
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
	mysqld_safe \
	mysqld_safe_helper \
	mysqldumpslow \
	mysqlhotcopy \
	perror \
	replace \
	resolve_stack_dump

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk

# Pass CPPFLAGS in the CFLAGS as otherwise the build system will
# ignore them.
TARGET_CFLAGS+=$(TARGET_CPPFLAGS)

define Package/mariadb/install/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(2) $(1)/usr/bin
endef

define Package/mariadb/description/Default
MariaDB is a fast, stable and true multi-user, multi-threaded SQL
database server. SQL (Structured Query Language) is the most popular
database query language in the world. The main goals of MariaDB are
speed, robustness and ease of use.
endef

define Package/libmariadbclient
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=$(MARIADB_COMMON_DEPENDS)
  TITLE:=MariaDB database client library
  URL:=https://mariadb.org/
  PROVIDES:=libmysqlclient libmysqlclient-r
endef

define Package/libmariadbclient/description
$(call Package/mariadb/description/Default)

This package includes the client library.

endef

define Package/mariadb/Default
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://mariadb.org/
  SUBMENU:=database
endef

define Package/mariadb-client
  $(call Package/mariadb/Default)
  TITLE:=MariaDB database core client binaries
  DEPENDS:= \
	  $(MARIADB_COMMON_DEPENDS) \
	  +libncursesw
endef

define Package/mariadb-client/description
$(call Package/mariadb/description/Default)

This package includes the following core client binaries:

$(subst $(space),$(newline),$(MARIADB_CLIENT))

endef

define Package/mariadb-client-extra
  $(call Package/mariadb/Default)
  TITLE:=MariaDB database extra client binaries
  DEPENDS:=mariadb-client
endef

define Package/mariadb-client-extra/description
$(call Package/mariadb/description/Default)

This package includes the following extra client binaries:

$(subst $(space),$(newline),$(MARIADB_CLIENT_EXTRA))

endef

define Package/mariadb-extra-charsets
  $(call Package/mariadb/Default)
  TITLE:=MariaDB database extra character sets
  DEPENDS:=mariadb-server
endef

define Package/mariadb-extra-charsets/description
$(call Package/mariadb/description/Default)

The MariaDB server packaged by OpenWrt only provides support for UTF-8.
This package contains single Byte character sets and collations that can
be added at run time.

endef

define Package/mariadb-server
  $(call Package/mariadb/Default)
  DEPENDS:= \
	  $(MARIADB_COMMON_DEPENDS) \
	  +!arc:libaio \
	  +liblzma \
	  +libpcre \
	  +resolveip
  TITLE:=MariaDB database core server binaries
  MENU:=1
  PROVIDES:=mysql-server
  USERID:=mariadb=376:mariadb=376
endef

define Package/mariadb-server/description
$(call Package/mariadb/description/Default)

This package includes the following core server binaries:

$(subst $(space),$(newline),$(MARIADB_SERVER))

endef

define Package/mariadb-server-extra
  $(call Package/mariadb/Default)
  TITLE:=MariaDB database extra server binaries
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

# Jemalloc was added for TokuDB. Since its configure script seems somewhat broken
# when it comes to cross-compilation we shall disable it and also disable TokuDB.
CMAKE_OPTIONS += -DWITH_JEMALLOC=no -DWITHOUT_TOKUDB=1

# Make it explicit that we are cross-compiling
CMAKE_OPTIONS += -DCMAKE_CROSSCOMPILING=1

# Explicitly disable dtrace to avoid detection of a host version
CMAKE_OPTIONS += -DENABLE_DTRACE=0

# Prevent mariadb from messing with OpenWrt's C(XX)FLAGS
CMAKE_OPTIONS += -DSECURITY_HARDENED=OFF

ifeq ($(CONFIG_PACKAGE_mariadb-server),)
CMAKE_OPTIONS += -DWITHOUT_SERVER=ON
else
CMAKE_OPTIONS += -DWITHOUT_SERVER=OFF
endif

CMAKE_OPTIONS += \
	-DCONNECT_WITH_JDBC=NO \
	-DCONNECT_WITH_LIBXML2=system \
	-DCONNECT_WITH_ODBC=NO \
	-DDEFAULT_CHARSET=utf8 \
	-DDEFAULT_COLLATION=utf8_general_ci \
	-DDISABLE_SHARED=NO \
	-DENABLED_PROFILING=OFF \
	-DENABLE_STATIC_LIBS=OFF \
	-DINSTALL_DOCDIR=share/doc/mariadb \
	-DINSTALL_DOCREADMEDIR=share/doc/mariadb \
	-DINSTALL_MANDIR=share/man \
	-DINSTALL_MYSQLSHAREDIR=share/mysql \
	-DINSTALL_MYSQLTESTDIR="" \
	-DINSTALL_PLUGINDIR=lib/mysql/plugin \
	-DINSTALL_SBINDIR=bin \
	-DINSTALL_SCRIPTDIR=bin \
	-DINSTALL_SQLBENCHDIR="" \
	-DINSTALL_SUPPORTFILESDIR=share/mysql \
	-DINSTALL_UNIX_ADDRDIR=/var/run/mysqld/mysqld.sock \
	-DMYSQLD_USER=mariadb \
	-DMYSQL_DATADIR=/var/lib/mysql \
	-DMYSQL_UNIX_ADDR=/var/run/mysqld/mysqld.sock \
	-DSKIP_TESTS=ON \
	-DWITH_ASAN=OFF \
	-DWITH_EMBEDDED_SERVER=OFF \
	-DWITH_EXTRA_CHARSETS=none \
	-DWITH_INNODB_BZIP2=OFF \
	-DWITH_INNODB_LZ4=OFF \
	-DWITH_INNODB_LZMA=ON \
	-DWITH_INNODB_LZO=OFF \
	-DWITH_INNODB_SNAPPY=OFF \
	-DWITH_LIBEDIT=OFF \
	-DWITH_LIBNUMA=NO \
	-DWITH_LIBWRAP=OFF \
	-DWITH_LIBWSEP=OFF \
	-DWITH_MARIABACKUP=ON \
	-DWITH_PCRE=system \
	-DWITH_READLINE=OFF \
	-DWITH_SAFEMALLOC=OFF \
	-DWITH_SSL=system \
	-DWITH_SYSTEMD=no \
	-DWITH_VALGRIND=OFF \
	-DWITH_ZLIB=system

# Default-disable some modules
CMAKE_OPTIONS += \
	-DPLUGIN_CASSANDRA=NO \
	-DPLUGIN_MROONGA=NO \
	-DPLUGIN_OQGRAPH=NO \
	-DPLUGIN_ROCKSDB=NO \
	-DPLUGIN_TOKUDB=NO \
	-DPLUGIN_AUTH_PAM=NO \
	-DPLUGIN_AUTH_GSSAPI=NO \
	-DPLUGIN_AUTH_GSSAPI_CLIENT=NO \
	-DPLUGIN_CRACKLIB_PASSWORD_CHECK=NO

CMAKE_OPTIONS += \
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
	-DWITHOUT_SERVER=OFF \
	-DWITHOUT_TOKUDB=1

# Some helpers must be compiled for host in order to crosscompile mariadb for
# the target. They are then included by import_executables.cmake which is
# generated during the build of the host helpers. It is not necessary to build
# the whole host package, only the "import_executables" target.
# -DIMPORT_EXECUTABLES=$(HOST_BUILD_DIR)/import_executables.cmake
# must then be passed to cmake during target build.
# See also https://mariadb.com/kb/en/mariadb/cross-compiling-mariadb/

CMAKE_OPTIONS += -DIMPORT_EXECUTABLES=$(STAGING_DIR_HOSTPKG)/share/mariadb/import_executables.cmake

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

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin $(1)/usr/bin $(1)/usr/include $(1)/usr/lib/mysql $(1)/usr/lib/pkgconfig $(1)/usr/share/aclocal
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mysql_config $(1)/usr/bin
	$(LN) $(STAGING_DIR)/usr/bin/mysql_config $(2)/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/include/mysql $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmysqlclient*.so* $(1)/usr/lib
	cd $(1)/usr/lib/mysql; $(LN) ../libmysqlclient*.so* .
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/pkgconfig/mariadb.pc $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/aclocal/mysql.m4 $(1)/usr/share/aclocal
endef

define Package/libmariadbclient/install
	$(INSTALL_DIR) $(1)$(PLUGIN_DIR)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmysqlclient*.so* $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)$(PLUGIN_DIR)/dialog.so $(1)$(PLUGIN_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)$(PLUGIN_DIR)/mysql_clear_password.so $(1)$(PLUGIN_DIR)
endef

define Package/mariadb-client/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(foreach b,$(MARIADB_CLIENT),$(call Package/mariadb/install/bin,$(1),$(b));)
	# Install convenience links for mysqlcheck multi-call binary
	cd $(1)/usr/bin; $(LN) mysqlcheck mysqlanalyze
	cd $(1)/usr/bin; $(LN) mysqlcheck mysqlrepair
	cd $(1)/usr/bin; $(LN) mysqlcheck mysqloptimize
endef

define Package/mariadb-client-extra/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(foreach b,$(MARIADB_CLIENT_EXTRA),$(call Package/mariadb/install/bin,$(1),$(b));)
endef

define Package/mariadb-extra-charsets/install
	$(INSTALL_DIR) $(1)/usr/share/mysql/charsets
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/mysql/charsets/* $(1)/usr/share/mysql/charsets
endef

define Package/mariadb-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(foreach b,$(MARIADB_SERVER),$(call Package/mariadb/install/bin,$(1),$(b));)
	$(INSTALL_DIR) $(1)/etc/default
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/mysql/conf.d
	$(INSTALL_BIN) files/mysqld.init $(1)/etc/init.d/mysqld
	$(INSTALL_CONF) conf/my.cnf $(1)/etc/mysql
	$(INSTALL_CONF) conf/mysqld.default $(1)/etc/default/mysqld
	$(INSTALL_DIR) $(1)$(PLUGIN_DIR)
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)$(PLUGIN_DIR)/daemon_example.ini $(1)$(PLUGIN_DIR)
	$(INSTALL_DIR) $(1)/usr/share/mysql/english
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/mysql/english/errmsg.sys $(1)/usr/share/mysql/english
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/mysql/fill_help_tables.sql $(1)/usr/share/mysql
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/mysql/maria_add_gis_sp_bootstrap.sql $(1)/usr/share/mysql
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/mysql/mysql_performance_tables.sql $(1)/usr/share/mysql
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/mysql/mysql_system_tables.sql $(1)/usr/share/mysql
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/mysql/mysql_system_tables_data.sql $(1)/usr/share/mysql
endef

define Package/mariadb-server-extra/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(foreach b,$(MARIADB_SERVER_EXTRA),$(call Package/mariadb/install/bin,$(1),$(b));)
endef

define Package/mariadb-server/conffiles
/etc/default/mysqld
/etc/mysql/my.cnf
$(PLUGIN_DIR)/daemon_example.ini
endef

define BuildPlugin
  define Package/$(PKG_NAME)-server-plugin-$(subst _,-,$(1))
    $$(call Package/mariadb/Default)
    TITLE:=MariaDB database plugin
    DEPENDS:=mariadb-server $(patsubst +%,+PACKAGE_$(PKG_NAME)-server-plugin-$(subst _,-,$(1)):%,$(2))
  endef
  define Package/$(PKG_NAME)-server-plugin-$(subst _,-,$(1))/description
    $$(call Package/mariadb/description/Default)

This package provides the $(1) plugin.

  endef
  define Package/$(PKG_NAME)-server-plugin-$(subst _,-,$(1))/install
  	$(INSTALL_DIR) $$(1)$(PLUGIN_DIR)
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)$(PLUGIN_DIR)/$(1).so \
		$$(1)$(PLUGIN_DIR)
  endef
  $$(eval $$(call BuildPackage,$(PKG_NAME)-server-plugin-$(subst _,-,$(1))))
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libmariadbclient))
$(eval $(call BuildPackage,mariadb-client))
$(eval $(call BuildPackage,mariadb-client-extra))
$(eval $(call BuildPackage,mariadb-extra-charsets))
$(eval $(call BuildPackage,mariadb-server))
$(eval $(call BuildPackage,mariadb-server-extra))

$(eval $(call BuildPlugin,adt_null,))
$(eval $(call BuildPlugin,auth_0x0100,))
$(eval $(call BuildPlugin,auth_ed25519,))
$(eval $(call BuildPlugin,auth_socket,))
$(eval $(call BuildPlugin,auth_test_plugin,))
$(eval $(call BuildPlugin,client_ed25519,))
$(eval $(call BuildPlugin,debug_key_management,))
$(eval $(call BuildPlugin,dialog_examples,))
$(eval $(call BuildPlugin,disks,))
$(eval $(call BuildPlugin,example_key_management,))
$(eval $(call BuildPlugin,feedback,))
$(eval $(call BuildPlugin,file_key_management,))
$(eval $(call BuildPlugin,ha_archive,))
$(eval $(call BuildPlugin,ha_blackhole,))
$(eval $(call BuildPlugin,ha_connect,+libxml2))
$(eval $(call BuildPlugin,ha_example,))
$(eval $(call BuildPlugin,ha_federated,))
$(eval $(call BuildPlugin,ha_federatedx,))
$(eval $(call BuildPlugin,ha_innodb,))
$(eval $(call BuildPlugin,ha_sequence,))
$(eval $(call BuildPlugin,ha_sphinx,))
$(eval $(call BuildPlugin,ha_spider,))
$(eval $(call BuildPlugin,ha_test_sql_discovery,))
$(eval $(call BuildPlugin,handlersocket,))
$(eval $(call BuildPlugin,libdaemon_example,))
$(eval $(call BuildPlugin,locales,))
$(eval $(call BuildPlugin,metadata_lock_info,))
$(eval $(call BuildPlugin,mypluglib,))
$(eval $(call BuildPlugin,qa_auth_client,))
$(eval $(call BuildPlugin,qa_auth_interface,))
$(eval $(call BuildPlugin,qa_auth_server,))
$(eval $(call BuildPlugin,query_cache_info,))
$(eval $(call BuildPlugin,query_response_time,))
$(eval $(call BuildPlugin,semisync_master,))
$(eval $(call BuildPlugin,semisync_slave,))
$(eval $(call BuildPlugin,server_audit,))
$(eval $(call BuildPlugin,simple_password_check,))
$(eval $(call BuildPlugin,sql_errlog,))
$(eval $(call BuildPlugin,wsrep_info,))
