# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=psqlodbc
PKG_RELEASE:=1
PKG_VERSION:=09.06.0310
PKG_HASH:=6c42078af094d61baca2c8bd1dc4d137a77377198ef94e4eda5989bdce3474c3

PKG_SOURCE_URL:=https://ftp.postgresql.org/pub/odbc/versions/src/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_LICENSE:=LGPL-2.0+
PKG_LICENSE_FILES:=license.txt

PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=unixodbc/host

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--with-unixodbc=$(STAGING_DIR)/usr \
	--with-libpq=$(STAGING_DIR)/usr

define Package/psqlodbc/Default
  SUBMENU:=database
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
