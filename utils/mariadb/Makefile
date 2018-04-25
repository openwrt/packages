#
# Copyright (C) 2017 Lucian Cristian
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mariadb
PKG_VERSION:=5.5.58
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=\
	http://ftp.hosteurope.de/mirror/archive.mariadb.org/$(PKG_NAME)-$(PKG_VERSION)/source/ \
	https://mirror.netcologne.de/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)/source/ \
	https://mirror.lstn.net/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)/source/ \
	http://lon1.mirrors.digitalocean.com/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)/source/ \
	http://ftp.kaist.ac.kr/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)/source/ \
	http://ftp.utexas.edu/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)/source/
PKG_HASH:=26fdf8784a51e5d6f7624c0f4528433a6188065dd1bf92ef69e27db6b0a41002
PKG_MAINTAINER:=Lucian Cristian <lucian.cristian@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_BUILD_DEPENDS:=mariadb/host libncurses libreadline
HOST_BUILD_DEPENDS += mariadb/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

PKG_FIXUP:=libtool

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/libmariadb
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libstdcpp +zlib +libpthread +libncurses +libreadline
  TITLE:=MariaDB client library
  URL:=http://mariadb.org/
  PROVIDES:=libmysqlclient libmysqlclient-r mariadb
  CONFLICTS:=libmysqlclient libmysqlclient-r
endef

define Package/mariadb/Default
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=mariadb
  TITLE:=MariaDB
  URL:=http://mariadb.org/
  SUBMENU:=database
endef

define Package/mariadb
  $(call Package/mariadb/Default)
  DEPENDS:=+libmariadb
  MENU:=1
endef

define Package/mariadb/description
 One of the most popular database servers. Made by the original developers of MySQL.
endef

define Package/mariadb-client
  $(call Package/mariadb/Default)
  TITLE+= client applications
  DEPENDS+=+libmariadb
endef

define Package/mariadb-client-extra
  $(call Package/mariadb/Default)
  DEPENDS+=+mariadb-client
  TITLE+= additional client applications
endef

define Package/mariadb-server/config
	menu "Select additional options"
	depends on PACKAGE_mariadb-server
	config MARIADB_LITE
		bool "Mariadb server lite, 5M vs 20M compressed"
		default y
		help
			Don't add plugins and other storage engines
	endmenu
endef

define Package/mariadb-server
  $(call Package/mariadb/Default)
  TITLE+= server
ifdef CONFIG_MARIADB_LITE
  DEPENDS+=+libmariadb +resolveip
else
  DEPENDS+=+libmariadb +libpam +libpcre +resolveip
endif
  PROVIDES:=mysql-server
  CONFLICTS:=mysql-server
endef


CMAKE_OPTIONS += -DSTACK_DIRECTION=-1
CMAKE_OPTIONS += -DWITHOUT_TOKUDB=1
CMAKE_OPTIONS += -DWITHOUT_HANDLERSOCKET=1
CMAKE_OPTIONS += -DWITHOUT_DAEMON_EXAMPLE=1
ifdef CONFIG_MARIADB_LITE
CMAKE_OPTIONS += -DWITH_ARIA_STORAGE_ENGINE=OFF
CMAKE_OPTIONS += -DWITHOUT_ARCHIVE=1
CMAKE_OPTIONS += -DWITHOUT_BLACKHOLE=1
CMAKE_OPTIONS += -DWITHOUT_EXAMPLE=1
CMAKE_OPTIONS += -DWITHOUT_FEDERATED=1
CMAKE_OPTIONS += -DWITHOUT_FEDERATEDX=1
CMAKE_OPTIONS += -DWITHOUT_PERFSCHEMA=1
CMAKE_OPTIONS += -DWITHOUT_SPHINX=1
CMAKE_OPTIONS += -DWITHOUT_XTRADB=1
CMAKE_OPTIONS += -DWITH_JEMALLOC=no
CMAKE_OPTIONS += -DWITH_EXTRA_CHARSETS=none
CMAKE_OPTIONS += -DWITH_QUERY_CACHE_INFO=OFF
CMAKE_OPTIONS += -DWITH_SAFEMALLOC=OFF
CMAKE_OPTIONS += -DWITHOUT_AUDIT_NULL=1
CMAKE_OPTIONS += -DWITHOUT_AUTH_PAM=1
CMAKE_OPTIONS += -DWITHOUT_QA_AUTH_CLIENT=1
CMAKE_OPTIONS += -DWITHOUT_QA_AUTH_INTERFACE=1
CMAKE_OPTIONS += -DWITHOUT_QA_AUTH_SERVER=1
CMAKE_OPTIONS += -DWITHOUT_AUTH_TEST_PLUGIN=1
CMAKE_OPTIONS += -DWITHOUT_FEEDBACK=1
CMAKE_OPTIONS += -DWITHOUT_FTEXAMPLE=1
CMAKE_OPTIONS += -DWITHOUT_QUERY_CACHE_INFO=1
CMAKE_OPTIONS += -DWITHOUT_SEMISYNC_MASTER=1
CMAKE_OPTIONS += -DWITHOUT_SEMISYNC_SLAVE=1
CMAKE_OPTIONS += -DWITHOUT_SERVER_AUDIT=1
endif
CMAKE_OPTIONS += -DIMPORT_EXECUTABLES=$(HOST_BUILD_DIR)/host/import_executables.cmake

define Host/Patch/Default
endef

NUM_CORES ?= $(shell grep -c "vendor_id" /proc/cpuinfo)

define Host/Compile
	( cd $(HOST_BUILD_DIR)/ ; mkdir host/ ; cd host ; cmake -DWITHOUT_TOKUDB=1 .. ; $(MAKE) -j$(NUM_CORES) IMPORT_EXECUTABLES )
endef

define Host/Install
endef

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C "$(PKG_BUILD_DIR)" \
		SUBDIRS="include" \
		DESTDIR="$(PKG_INSTALL_DIR)"
	$(MAKE) -C "$(PKG_BUILD_DIR)" \
		SUBDIRS="include" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin $(1)/usr/bin $(1)/usr/include $(1)/usr/lib $(1)/usr/lib/mysql $(1)/usr/share/aclocal
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mysql_config $(1)/usr/bin/
	ln -sf $(STAGING_DIR)/usr/bin/mysql_config $(2)/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/mysql $(1)/usr/include/
	# NOTE: needed for MySQL-Python
	$(CP) $(PKG_BUILD_DIR)/include/mysqld_error.h $(1)/usr/include/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.a $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.a $(1)/usr/lib/mysql
	$(CP) $(PKG_INSTALL_DIR)/usr/share/aclocal/mysql.m4 $(1)/usr/share/aclocal/
endef

define Package/libmariadb/install
	$(INSTALL_DIR) $(1)/usr/lib $(1)/usr/lib/mysql
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmysqlclient*.so.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmysqlclient*.so $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/mysql_clear_password.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/dialog.so $(1)/usr/lib/mysql/
endef

define Package/mariadb-client/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysql $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysqlcheck $(1)/usr/bin/
endef

define Package/mariadb-client-extra/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/innochecksum $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysqlaccess $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysqladmin $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysqlbug $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysqldump $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysqldumpslow $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysql_find_rows $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysql_fix_extensions $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysqlimport $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysqlshow $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysqlslap $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysql_waitpid $(1)/usr/bin/
endef

define Package/mariadb-server/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/share/mysql $(1)/usr/share/mysql/english $(1)/usr/lib/mysql $(1)/etc/mysql $(1)/etc/mysql/conf.d $(1)/etc/init.d
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysqld $(1)/usr/bin/mysqld
	$(INSTALL_BIN) files/mariadb.init $(1)/etc/init.d/mariadb
	# these two need perl and should go into their own package which depends on perl + dbi + ?
	$(INSTALL_CONF) files/my.cnf $(1)/etc/mysql/
	$(INSTALL_CONF) files/conf.d/* $(1)/etc/mysql/conf.d/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/english/errmsg.sys $(1)/usr/share/mysql/english
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/fill_help_tables.sql $(1)/usr/share/mysql/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/mysql_performance_tables.sql $(1)/usr/share/mysql/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/mysql_system_tables.sql $(1)/usr/share/mysql/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/mysql_system_tables_data.sql $(1)/usr/share/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/auth_socket.so $(1)/usr/lib/mysql/
ifndef CONFIG_MARIADB_LITE
	# $(INSTALL_BIN) files/mysqlreport $(1)/usr/bin/
	# $(INSTALL_BIN) files/innotop $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/* $(1)/usr/share/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/auth_pam.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/adt_null.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/feedback.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/ha_archive.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/ha_blackhole.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/ha_federated.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/ha_federatedx.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/ha_sphinx.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/mypluglib.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/qa_auth_client.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/qa_auth_interface.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/qa_auth_server.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/query_cache_info.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/server_audit.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/semisync_master.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/semisync_slave.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/sphinx.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/msql2mysql $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/myisam_ftdump $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/myisamlog $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/myisampack $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/aria_pack $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/aria_read_log $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/aria_ftdump $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/aria_chk $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/aria_dump_log $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysql_convert_table_format $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysql_tzinfo_to_sql $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysqlbinlog $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysql_zap $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysqlhotcopy $(1)/usr/bin/
endif
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/ha_innodb.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/plugin/sql_errlog.so $(1)/usr/lib/mysql/
	$(CP) $(PKG_INSTALL_DIR)/usr/scripts/mysql_install_db $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/my_print_defaults $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/myisamchk $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysql_plugin $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysql_secure_installation $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysql_setpermission $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysql_upgrade $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysqld_multi $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysqld_safe $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mysqld_safe_helper $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/perror $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/replace $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/resolve_stack_dump $(1)/usr/bin/
endef

define Package/mariadb/conffiles
/etc/mysql/my.cnf
/etc/mysql/conf.d
endef

$(eval $(call HostBuild))

$(eval $(call BuildPackage,libmariadb))
$(eval $(call BuildPackage,mariadb))
$(eval $(call BuildPackage,mariadb-client))
$(eval $(call BuildPackage,mariadb-client-extra))
$(eval $(call BuildPackage,mariadb-server))
