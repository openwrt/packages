#
# Copyright (C) 2021 Michal Hrusecky <michal@hrusecky.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mariadb
PKG_VERSION:=11.4.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL := https://archive.mariadb.org/$(PKG_NAME)-$(PKG_VERSION)/source

PKG_HASH:=52fa4dca2c5f80afc1667d523a27c06176d98532298a6b0c31ed73505f49e15c
PKG_MAINTAINER:=Michal Hrusecky <Michal@Hrusecky.net>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING THIRDPARTY

PKG_CPE_ID:=cpe:/a:mariadb:mariadb

PKG_BUILD_FLAGS:=no-mips16

HOST_BUILD_DEPENDS:=libxml2/host
# Without libevent2 tests/async_queries sporadically fails on the bots
PKG_BUILD_DEPENDS:=libevent2 mariadb/host

CONF_DIR:=/etc/mysql
PLUGIN_DIR:=/usr/lib/mariadb/plugin
SHARE_DIR:=/usr/share/mariadb

MARIADB_SOCKET=/var/run/mysql/mysql.sock

MARIADB_DISABLE_ENGINES := \
	columnstore \
	example \
	mroonga \
	oqgraph \
	rocksdb \
	test_sql_discovery

MARIADB_DISABLE_PLUGINS := \
	audit_null \
	auth_examples \
	aws_key_management \
	cracklib_password_check \
	daemon_example \
	debug_key_management \
	example_key_management \
	fulltext \
	versioning

MARIADB_SERVER_PLUGINS := \
	auth_ed25519 \
	auth_gssapi \
	auth_pam \
	auth_pam_v1 \
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
	server_audit \
	simple_password_check \
	sql_errlog \
	wsrep_info

PKG_CONFIG_DEPENDS := \
	$(patsubst %,CONFIG_PACKAGE_$(PKG_NAME)-server-plugin-%,$(subst _,-,$(MARIADB_SERVER_PLUGINS))) \
	CONFIG_KERNEL_IO_URING \
	CONFIG_PACKAGE_mariadb-server

plugin-auth_ed25519             := PLUGIN_AUTH_ED25519
plugin-auth_gssapi              := PLUGIN_AUTH_GSSAPI
plugin-auth_pam                 := PLUGIN_AUTH_PAM
plugin-auth_pam_v1              := PLUGIN_AUTH_PAM_V1
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
plugin-server_audit             := PLUGIN_SERVER_AUDIT
plugin-simple_password_check    := PLUGIN_SIMPLE_PASSWORD_CHECK
plugin-sql_errlog               := PLUGIN_SQL_ERRLOG
plugin-wsrep_info               := PLUGIN_WSREP_INFO

MARIADB_CLIENT := \
	mysql \
	mysqlcheck

MARIADB_CLIENT_EXTRA := \
	msql2mysql \
	mysql_find_rows \
	mysql_plugin \
	mysql_waitpid \
	mysqlaccess \
	mysqlbinlog \
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
	mysqladmin \
	mysqld

MARIADB_SERVER_EXTRA := \
	aria_chk \
	aria_dump_log \
	aria_ftdump \
	aria_pack \
	aria_read_log \
	mariabackup \
	myisam_ftdump \
	myisamchk \
	myisamlog \
	myisampack \
	mysql_convert_table_format \
	mysql_fix_extensions \
	mysql_secure_installation \
	mysql_setpermission \
	mysql_tzinfo_to_sql \
	mysqld_multi \
	mysqld_safe \
	mysqld_safe_helper \
	mysqldumpslow \
	mysqlhotcopy \
	perror \
	replace \
	resolve_stack_dump \
	wsrep_sst_mariabackup \
	wsrep_sst_mysqldump \
	wsrep_sst_rsync \
	wsrep_sst_rsync_wan

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/cmake.mk

MARIADB_COMMON_DEPENDS := \
	$(ICONV_DEPENDS) \
	+libatomic \
	+libfmt \
	+libopenssl \
	+libstdcpp \
	+zlib

# Pass CPPFLAGS in the CFLAGS as otherwise the build system will
# ignore them.
TARGET_CFLAGS+=$(TARGET_CPPFLAGS)

ifneq ($(CONFIG_USE_MUSL),)
  TARGET_CFLAGS += -D_LARGEFILE64_SOURCE
endif

define Package/mariadb/disable/engine
	echo > $(1)/storage/$(2)/CMakeLists.txt
endef

define Package/mariadb/disable/plugin
	echo > $(1)/plugin/$(2)/CMakeLists.txt
endef

define Package/mariadb/install/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(2) $(1)/usr/bin
	[ $(2) = $(subst mysql,mariadb,$(2)) ] || ln -s $(2) $(1)/usr/bin/$(subst mysql,mariadb,$(2))
	[ $(2) = $(subst mariadb,mysql,$(2)) ] || ln -s $(2) $(1)/usr/bin/$(subst mariadb,mysql,$(2))
endef

define Package/mariadb/install/plugin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)$(PLUGIN_DIR)/$(2).so $(1)$(PLUGIN_DIR)
endef

define Package/mariadb/description/Default
MariaDB is a very fast and robust SQL database server.
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
  DEPENDS:=$(MARIADB_COMMON_DEPENDS) \
	  +libedit
endef

define Package/mariadb-client/description
$(call Package/mariadb/description/Default)

This package includes the following core client binaries:

$(subst $(space),$(newline),$(MARIADB_CLIENT))

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
  DEPENDS:= \
	  $(MARIADB_COMMON_DEPENDS) \
	  +!KERNEL_IO_URING:libaio \
	  +KERNEL_IO_URING:liburing \
	  +liblzma \
	  +libpcre2 \
	  +resolveip \
	  +sudo
  TITLE:=MariaDB database server base
  USERID:=mariadb=376:mariadb=376
endef

define Package/mariadb-server-base/conffiles
$(CONF_DIR)/my.cnf
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

# Make it explicit that we are cross-compiling
CMAKE_OPTIONS += -DCMAKE_CROSSCOMPILING=1

# Apply workaround to pass LIBFMT check when cross-compiling
CMAKE_OPTIONS += -DHAVE_SYSTEM_LIBFMT_EXITCODE=0

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
	-DCMAKE_DISABLE_FIND_PACKAGE_URING=$(if $(CONFIG_KERNEL_IO_URING),OFF,ON) \
	-DCONNECT_WITH_JDBC=NO \
	-DCONNECT_WITH_LIBXML2=system \
	-DCONNECT_WITH_MONGO=NO \
	-DCONNECT_WITH_ODBC=NO \
	-DDISABLE_SHARED=NO \
	-DDEFAULT_CHARSET=utf8mb4 \
	-DDEFAULT_COLLATION=utf8mb4_general_ci \
	-DENABLED_PROFILING=OFF \
	-DENABLE_STATIC_LIBS=OFF \
	-DINSTALL_DOCDIR=share/doc/mariadb \
	-DINSTALL_DOCREADMEDIR=share/doc/mariadb \
	-DINSTALL_INFODIR=share/info \
	-DINSTALL_MANDIR=share/man \
	-DINSTALL_MYSQLSHAREDIR=share/mariadb \
	-DINSTALL_MYSQLTESTDIR="" \
	-DINSTALL_PAMDATADIR="/etc/security" \
	-DINSTALL_PAMDIR="/lib/security" \
	-DINSTALL_PLUGINDIR=lib/mariadb/plugin \
	-DINSTALL_PREFIX="/usr" \
	-DINSTALL_SBINDIR=bin \
	-DINSTALL_SCRIPTDIR=bin \
	-DINSTALL_SQLBENCHDIR="" \
	-DINSTALL_SUPPORTFILESDIR=share/mariadb \
	-DINSTALL_UNIX_ADDRDIR=$(MARIADB_SOCKET) \
	-DHOSTNAME="uci get system.@system[0].hostname" \
	-DMYSQL_DATADIR=/srv/mysql \
	-DMYSQL_UNIX_ADDR=$(MARIADB_SOCKET) \
	-DSEMODULE_PACKAGE_EXECUTABLE=NOT-FOUND \
	-DSKIP_TESTS=ON \
	-DWITH_EMBEDDED_SERVER=OFF \
	-DWITH_INNODB_BZIP2=OFF \
	-DWITH_INNODB_LZ4=OFF \
	-DWITH_INNODB_LZMA=ON \
	-DWITH_INNODB_LZO=OFF \
	-DWITH_INNODB_SNAPPY=OFF \
	-DWITH_JEMALLOC=OFF \
	-DWITH_LIBAIO=$(if $(CONFIG_KERNEL_IO_URING),OFF,ON) \
	-DWITH_LIBARCHIVE=OFF \
	-DWITH_LIBFMT=system \
	-DWITH_LIBWRAP=OFF \
	-DWITH_MARIABACKUP=ON \
	-DWITH_NUMA=OFF \
	-DWITH_PCRE=system \
	-DWITH_SAFEMALLOC=OFF \
	-DWITH_SSL=system \
	-DWITH_SYSTEMD=no \
	-DWITH_URING=$(if $(CONFIG_KERNEL_IO_URING),ON,OFF) \
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
	$(foreach p,$(MARIADB_SERVER_PLUGINS),-D$(plugin-$(p))=$(if $(CONFIG_PACKAGE_$(PKG_NAME)-server-plugin-$(subst _,-,$(p))),DYNAMIC,NO))

# Disable some client library plugins
CMAKE_OPTIONS += \
	-DCLIENT_PLUGIN_AUTH_GSSAPI_CLIENT=OFF \
	-DCLIENT_PLUGIN_REMOTE_IO=OFF

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
	$(INSTALL_DIR) $(1)/share/mariadb/{dbug,extra,scripts,sql,strings}
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/dbug/factorial $(1)/share/mariadb/dbug
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/extra/comp_err $(1)/share/mariadb/extra
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/scripts/comp_sql $(1)/share/mariadb/scripts
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/sql/{gen_lex_hash,gen_lex_token} $(1)/share/mariadb/sql
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/strings/uca-dump $(1)/share/mariadb/strings
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
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)$(SHARE_DIR)/wsrep.cnf $(1)$(CONF_DIR)/conf.d/60-galera.cnf
	$(INSTALL_DATA) conf/50-server.cnf $(1)$(CONF_DIR)/conf.d
	$(INSTALL_DATA) conf/my.cnf $(1)$(CONF_DIR)
	$(INSTALL_CONF) files/mysqld.config $(1)/etc/config/mysqld
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)$(SHARE_DIR)/charsets/* $(1)$(SHARE_DIR)/charsets
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)$(SHARE_DIR)/english/errmsg.sys $(1)$(SHARE_DIR)/english
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)$(SHARE_DIR)/*.sql $(1)$(SHARE_DIR)
endef

define Package/mariadb-server-extra/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/bin/wsrep_sst_common $(1)/usr/bin
	$(SED) 's,/bin/bash,/bin/sh,g' $(PKG_INSTALL_DIR)/usr/bin/wsrep_sst_*
	$(foreach b,$(MARIADB_SERVER_EXTRA),$(call Package/mariadb/install/bin,$(1),$(b));)
	cd $(1)/usr/bin; $(LN) mariabackup mariadb-backup
endef

define BuildPlugin
  define Package/mariadb-server-plugin-$(subst _,-,$(1))
    $(call Package/mariadb/Default)
    TITLE:=mariadb-server plugin
    DEPENDS:=mariadb-server $(patsubst +%,+PACKAGE_mariadb-server-plugin-$(subst _,-,$(1)):%,$(2))
ifeq ($(1),auth_pam)
    # Directory "auth_pam_tool_dir" is installed with mode 0750 and is only
    # accessible by root and the group mariadb. This way mariadb can access
    # the SUID binary "auth_pam_tool" contained within while others cannot.
    FILE_MODES:=/usr/lib/mariadb/plugin/auth_pam_tool_dir:root:mariadb:0750
endif
  endef
  define Package/mariadb-server-plugin-$(subst _,-,$(1))/description
    $(call Package/mariadb/description/Default)

This package provides the $(1) plugin.

  endef
  define Package/mariadb-server-plugin-$(subst _,-,$(1))/install
	  $(INSTALL_DIR) $$(1)$(PLUGIN_DIR)
	  $(call Package/mariadb/install/plugin,$$(1),$(1))
ifeq ($(1),auth_pam)
	  $(INSTALL_DIR) $$(1)$(PLUGIN_DIR)/auth_pam_tool_dir
	  $(INSTALL_SUID) \
		  $(PKG_INSTALL_DIR)$(PLUGIN_DIR)/auth_pam_tool_dir/auth_pam_tool \
					  $$(1)$(PLUGIN_DIR)/auth_pam_tool_dir
	  $(INSTALL_DIR) $$(1)/etc/security
	  $(INSTALL_DATA) \
		  $(PKG_INSTALL_DIR)/etc/security/user_map.conf \
					  $$(1)/etc/security
	  $(INSTALL_DIR) $$(1)/lib/security
	  $(INSTALL_DATA) \
		  $(PKG_INSTALL_DIR)/lib/security/pam_user_map.so \
					  $$(1)/lib/security
endif
  endef
  $$(eval $$(call BuildPackage,mariadb-server-plugin-$(subst _,-,$(1))))
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,mariadb-client))
$(eval $(call BuildPackage,mariadb-client-extra))
$(eval $(call BuildPackage,mariadb-server))
$(eval $(call BuildPackage,mariadb-server-base))
$(eval $(call BuildPackage,mariadb-server-extra))

$(eval $(call BuildPlugin,auth_ed25519,))
$(eval $(call BuildPlugin,auth_gssapi,+krb5-libs))
$(eval $(call BuildPlugin,auth_pam,+libpam))
$(eval $(call BuildPlugin,auth_pam_v1,+libpam))
$(eval $(call BuildPlugin,disks,))
$(eval $(call BuildPlugin,feedback,))
$(eval $(call BuildPlugin,file_key_management,))
$(eval $(call BuildPlugin,ha_archive,))
$(eval $(call BuildPlugin,ha_blackhole,))
$(eval $(call BuildPlugin,ha_connect,+libxml2))
$(eval $(call BuildPlugin,ha_federated,))
$(eval $(call BuildPlugin,ha_federatedx,))
$(eval $(call BuildPlugin,ha_sphinx,))
$(eval $(call BuildPlugin,ha_spider,))
$(eval $(call BuildPlugin,handlersocket,))
$(eval $(call BuildPlugin,locales,))
$(eval $(call BuildPlugin,metadata_lock_info,))
$(eval $(call BuildPlugin,query_cache_info,))
$(eval $(call BuildPlugin,query_response_time,))
$(eval $(call BuildPlugin,server_audit,))
$(eval $(call BuildPlugin,simple_password_check,))
$(eval $(call BuildPlugin,sql_errlog,))
$(eval $(call BuildPlugin,wsrep_info,))
