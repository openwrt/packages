#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=unixodbc
PKG_VERSION:=2.3.4
PKG_RELEASE:=5

PKG_SOURCE_URL:=ftp://ftp.unixodbc.org/pub/unixODBC/
PKG_SOURCE:=unixODBC-$(PKG_VERSION).tar.gz
PKG_HASH:=2e1509a96bb18d248bf08ead0d74804957304ff7c6f8b2e5965309c632421e39
PKG_BUILD_DIR:=$(BUILD_DIR)/unixODBC-$(PKG_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/unixODBC-$(PKG_VERSION)
PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de>
PKG_LICENSE:=prog GPL libs LGPL
HOST_BUILD_DEPENDS:=unixodbc

# if your other package depends on unixodbc and needs
# odbc_config, add to your other Makefile
#  PKG_BUILD_DEPENDS:=unixodbc/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

CONFIGURE_ARGS += \
	--disable-gui \
	--with-pic \
	--enable-drivers \
	--includedir=$(STAGING_DIR)/usr/include

define Package/unixodbc/Default
  SUBMENU:=database
  TITLE:=unixODBC
  URL:=http://www.unixodbc.org/
endef

define Package/unixodbc
  $(call Package/unixodbc/Default)
  TITLE+= (libraries)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libltdl +libpthread
endef

define Package/unixodbc/description
  unixODBC is an Open Source ODBC sub-system and an ODBC SDK for Linux,
  Mac OSX, and UNIX.
endef

define Package/unixodbc-tools
  $(call Package/unixodbc/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE+= Tools
  DEPENDS:=+unixodbc +libncurses +libreadline
endef

define Package/unixodbc-tools/description
  Command Line Tools to help install a driver and work with SQL.
endef

define Package/pgsqlodbc
  $(call Package/unixodbc/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Postgresql driver for ODBC
  DEPENDS:=+unixodbc +libpq
endef

define Package/pgsqlodbc/description
	Postgresql driver for ODBC.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		$(MAKE_FLAGS) \
		ARCH="$(ARCH)" \
		CC="$(TARGET_CC)"
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		$(MAKE_FLAGS) \
		ARCH="$(ARCH)" \
		install -i
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/$(STAGING_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc
	$(CP) $(PKG_INSTALL_DIR)/etc/odbc* $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/ODBCDataSources
	$(TARGET_CC) $(TARGET_CFLAGS) -E ./files/unixodbc_conf.h | tr '@' '\#' >$(1)/usr/include/unixodbc_conf.h
endef

define Package/unixodbc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libodbc[ci]*so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libodbc.*so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnn*so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/odbc.init $(1)/etc/init.d/odbc
	$(LN) /tmp/etc/odbcinst.ini $(1)/etc/odbcinst.ini
endef

define Package/unixodbc-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/{dltest,isql,iusql,odbcinst,slencheck} $(1)/usr/bin/
endef

define Package/pgsqlodbc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libodbcpsql*so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/odbcinst.ini.d/
	echo "[PostgreSQL]" > $(1)/etc/odbcinst.ini.d/pgsqlodbc.ini
	echo "Description = unixODBC PostgreSQL driver" >> $(1)/etc/odbcinst.ini.d/pgsqlodbc.ini
	echo "Driver = /usr/lib/libodbcpsql.so" >> $(1)/etc/odbcinst.ini.d/pgsqlodbc.ini
endef

define Host/Configure
	$(call Host/Configure/Default)
	cp $(PKG_BUILD_DIR)/config.h $(HOST_BUILD_DIR)
	cp $(PKG_BUILD_DIR)/unixodbc_conf.h $(HOST_BUILD_DIR)
endef

define Host/Compile
	$(MAKE) -C $(HOST_BUILD_DIR)/exe \
		DESTDIR="$(HOST_INSTALL_DIR)" \
		CC="$(HOSTCC)" \
		CFLAGS="$(HOST_CFLAGS) -DUSE_UNIXODBC_CONF_H" \
		LDFLAGS="$(HOST_LDFLAGS)" \
		odbc_config
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOST)/bin
	$(CP) $(HOST_BUILD_DIR)/exe/odbc_config $(STAGING_DIR_HOST)/bin
endef

$(eval $(call BuildPackage,unixodbc))
$(eval $(call BuildPackage,unixodbc-tools))
$(eval $(call BuildPackage,pgsqlodbc))
$(eval $(call HostBuild))
