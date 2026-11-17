# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=psqlodbc
PKG_VERSION:=18.00.0001
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/postgresql-interfaces/psqlodbc.git
PKG_SOURCE_DATE:=2026-03-23
PKG_SOURCE_VERSION:=b4897ee1ac17688f557b81a7869080a3f3bbf498
PKG_MIRROR_HASH:=99248d25e438bf44ad3f57b23e3b9bf0ef12174951b2a9d7138d1a0c27ad13f5

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=LGPL-2.0-or-later
PKG_LICENSE_FILES:=license.txt

PKG_FIXUP = autoreconf
PKG_BUILD_DEPENDS:=unixodbc/host
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--with-unixodbc=$(STAGING_DIR)/host/bin/odbc_config \
	--with-libpq=$(STAGING_DIR)/usr

define Package/psqlodbc/Default
  SUBMENU:=Database
  URL:=https://odbc.postgresql.org/
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Postgresql driver for ODBC
  DEPENDS:=+unixodbc +libpq
endef

define Package/psqlodbca
$(call Package/psqlodbc/Default)
  TITLE:=psqlODBC - PostgreSQL ODBC driver (ASCII)
endef

define Package/psqlodbcw
$(call Package/psqlodbc/Default)
  TITLE:=psqlODBC - PostgreSQL ODBC driver (UTF-8)
endef

define Package/psqlodbca/description
	psqlODBC is the official PostgreSQL ODBC Driver.
	It is released under the Library General Public Licence, or LGPL.
endef

define Package/psqlodbcw/description
$(call Package/psqlodbca/description)
	(UTF-8 version)
endef

define Package/psqlodbca/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/psqlodbca.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/odbcinst.ini.d
	echo "[PostgreSQL ANSI]" > $(1)/etc/odbcinst.ini.d/psqlodbca.ini
	echo "Description = PostgreSQL ODBC driver (ANSI version)" >> $(1)/etc/odbcinst.ini.d/psqlodbca.ini
	echo "Driver = /usr/lib/psqlodbca.so" >> $(1)/etc/odbcinst.ini.d/psqlodbca.ini

endef

define Package/psqlodbcw/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/psqlodbcw.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/odbcinst.ini.d
	echo "[PostgreSQL Unicode]" > $(1)/etc/odbcinst.ini.d/psqlodbcw.ini
	echo "Description = PostgreSQL ODBC driver (Unicode version)" >> $(1)/etc/odbcinst.ini.d/psqlodbcw.ini
	echo "Driver = /usr/lib/psqlodbcw.so" >> $(1)/etc/odbcinst.ini.d/psqlodbcw.ini
endef

$(eval $(call BuildPackage,psqlodbca))
$(eval $(call BuildPackage,psqlodbcw))
