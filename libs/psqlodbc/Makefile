# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=psqlodbc
PKG_VERSION:=17.00.0004
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/postgresql-interfaces/psqlodbc.git
PKG_SOURCE_DATE:=2024-12-09
PKG_SOURCE_VERSION:=20097cdf913de593b17d8aa9ec163de4e12896c0
PKG_MIRROR_HASH:=177001d0f0cbb530ec4d7a4666785c07fd5563ef9cf58a5ebf311cbb68c419f0

PKG_MAINTAINER:=
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
