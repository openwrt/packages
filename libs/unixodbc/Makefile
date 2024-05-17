#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=unixodbc
PKG_VERSION:=2.3.12
PKG_RELEASE:=2

PKG_SOURCE:=unixODBC-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.unixodbc.org
PKG_HASH:=f210501445ce21bf607ba51ef8c125e10e22dffdffec377646462df5f01915ec

PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de>
PKG_LICENSE:=LGPL-2.1-or-later GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING exe/COPYING
PKG_CPE_ID:=cpe:/a:unixodbc:unixodbc

PKG_BUILD_DIR:=$(BUILD_DIR)/unixODBC-$(PKG_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR)/host/unixODBC-$(PKG_VERSION)

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

HOST_BUILD_DEPENDS:=unixodbc
HOST_BUILD_PARALLEL:=1

# if your other package depends on unixodbc and needs
# odbc_config, add to your other Makefile
#  PKG_BUILD_DEPENDS:=unixodbc/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

CONFIGURE_ARGS += \
	--disable-gui \
	--with-pic \
	--enable-drivers

define Package/unixodbc/Default
  SUBMENU:=Database
  TITLE:=unixODBC
  URL:=https://www.unixodbc.org
endef

define Package/unixodbc/Default/description
unixODBC is an Open Source ODBC sub-system and an ODBC SDK for Linux,
Mac OSX, and UNIX.
endef

define Package/libodbc
$(call Package/unixodbc/Default)
  TITLE+= Driver Manager library
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libltdl +libpthread
  ABI_VERSION:=2
endef

define Package/libodbc/description
$(call Package/unixodbc/Default/description)

This package provides the unixODBC Driver Manager library.
endef

define Package/libodbccr
$(call Package/unixodbc/Default)
  TITLE+= Cursor library
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libodbc +libltdl +libpthread
  ABI_VERSION:=2
endef

define Package/libodbccr/description
$(call Package/unixodbc/Default/description)

This package provides the unixODBC Cursor library.
endef

define Package/libodbcinst
$(call Package/unixodbc/Default)
  TITLE+= Configuration library
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libltdl +libpthread
  ABI_VERSION:=2
endef

define Package/libodbcinst/description
$(call Package/unixodbc/Default/description)

This package provides the unixODBC Configuration library.
endef

define Package/unixodbc
$(call Package/unixodbc/Default)
  TITLE+= (libraries)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libodbc +libodbccr +libodbcinst
endef

define Package/unixodbc/description
$(call Package/unixodbc/Default/description)

This package installs the unixODBC Driver Manager, Cursor, and
Configuration libraries. This package is provided for backwards
compatibility; these libraries are available in separate packages.
endef

define Package/unixodbc-tools
$(call Package/unixodbc/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE+= Tools
  DEPENDS:=+libodbc +libodbcinst +libltdl +libreadline
endef

define Package/unixodbc-tools/description
$(call Package/unixodbc/Default/description)

This package provides command-line tools to help install a driver and
work with SQL.
endef

define Package/pgsqlodbc
$(call Package/unixodbc/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=PostgreSQL driver for ODBC
  DEPENDS:=+libodbc +libpq +libltdl +libpthread
  ABI_VERSION:=2
endef

define Package/pgsqlodbc/description
$(call Package/unixodbc/Default/description)

This package provides the PostgreSQL driver for ODBC.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	# Save autoconf config.h file for host build
	# copy target autoconf config.h and unixodbc_conf.h file for host build
	$(INSTALL_DIR) $(1)/usr/include/unixodbc
	$(CP) $(PKG_BUILD_DIR)/config.h $(1)/usr/include/unixodbc/
	$(CP) $(PKG_BUILD_DIR)/unixodbc_conf.h $(1)/usr/include/unixodbc/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc
	$(CP) $(PKG_INSTALL_DIR)/etc/odbc* $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/ODBCDataSources
endef

define Package/libodbc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libodbc.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/odbc.init $(1)/etc/init.d/odbc
	$(LN) /tmp/etc/odbcinst.ini $(1)/etc/odbcinst.ini
endef

define Package/libodbccr/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libodbccr.so* $(1)/usr/lib/
endef

define Package/libodbcinst/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libodbcinst.so* $(1)/usr/lib/
endef

Package/unixodbc/install:=:

define Package/unixodbc-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/{dltest,isql,iusql,odbcinst,slencheck} $(1)/usr/bin/
endef

define Package/pgsqlodbc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libodbcpsql.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/odbcinst.ini.d/
	$(INSTALL_DATA) ./files/pgsqlodbc.ini $(1)/etc/odbcinst.ini.d/
endef

define Host/Configure
	$(call Host/Configure/Default)
	$(CP) $(STAGING_DIR)/usr/include/unixodbc/config.h $(HOST_BUILD_DIR)
	$(CP) $(STAGING_DIR)/usr/include/unixodbc/unixodbc_conf.h $(HOST_BUILD_DIR)
	$(CP) $(STAGING_DIR)/usr/include/unixodbc.h $(HOST_BUILD_DIR)
	$(SED) 's!^#define INCLUDE_PREFIX ".*"!#define INCLUDE_PREFIX "$(STAGING_DIR)/usr/include"!' \
		-e 's!^#define LIB_PREFIX ".*"!#define LIB_PREFIX "$(STAGING_DIR)/usr/lib"!' \
		$(HOST_BUILD_DIR)/config.h \
		$(HOST_BUILD_DIR)/unixodbc_conf.h
endef

define Host/Compile
	$(call Host/Compile/Default,-C $(HOST_BUILD_DIR)/exe odbc_config)
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR)/host/bin
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/exe/odbc_config $(STAGING_DIR)/host/bin/
endef

$(eval $(call BuildPackage,libodbc))
$(eval $(call BuildPackage,libodbccr))
$(eval $(call BuildPackage,libodbcinst))
$(eval $(call BuildPackage,unixodbc))
$(eval $(call BuildPackage,unixodbc-tools))
$(eval $(call BuildPackage,pgsqlodbc))
$(eval $(call HostBuild))
