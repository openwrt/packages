include $(TOPDIR)/rules.mk

PKG_NAME:=gnunet-secushare

PKG_SOURCE_VERSION:=81939cb93670efcee8e99884d10d2676b02edba9
PKG_SOURCE_DATE:=20190228
PKG_MIRROR_HASH:=64a0fb7ad6a515559360de71df85dde152f55a60585668f15114bc1f55cf2742
PKG_RELEASE:=3
PKG_SOURCE_URL:=https://gnunet.org/git/gnunet-secushare.git
PKG_SOURCE_PROTO:=git
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=gettext-version
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/gnunet-secushare
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNUnet Secushare
  URL:=https://www.secushare.org/
  DEPENDS:=gnunet +gnunet-reclaim
endef

define Package/gnunet-secushare-mysql
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNUnet Secushare (mySQL)
  URL:=https://www.secushare.org/
  DEPENDS:=gnunet +gnunet-secushare +gnunet-mysql
endef

define Package/gnunet-secushare-pgsql
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNUnet Secushare (PostgreSQL)
  URL:=https://www.secushare.org/
  DEPENDS:=gnunet +gnunet-secushare +gnunet-pgsql
endef

define Package/gnunet-secushare-sqlite
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNUnet Secushare (SQLite)
  URL:=https://www.secushare.org/
  DEPENDS:=gnunet +gnunet-secushare +gnunet-sqlite
endef


CONFIGURE_ARGS+= \
	--with-libiconv-prefix="$(ICONV_PREFIX)" \
	--with-libintl-prefix="$(INTL_PREFIX)" \
	--with-gnunet="$(STAGING_DIR)/usr" \
	$(if $(CONFIG_PACKAGE_$(PKG_NAME)-mysql),--with-mysql="$(STAGING_DIR)/usr",--without-mysql) \
	$(if $(CONFIG_PACKAGE_$(PKG_NAME)-pgsql),--with-postgresql="$(STAGING_DIR)/usr/bin/pg_config",--without-postgresql) \
	$(if $(CONFIG_PACKAGE_$(PKG_NAME)-sqlite),--with-sqlite="$(STAGING_DIR)/usr",--without-sqlite) \
	--enable-testing \
	--disable-testruns \
	--enable-experimental

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/gnunet $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{la,so}* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gnunet/*.h $(1)/usr/include/gnunet
endef

define Package/gnunet-secushare/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/gnunet $(1)/usr/lib/gnunet-secushare/libexec
	$(INSTALL_DIR) $(1)/usr/share/gnunet-secushare/config.d $(1)/usr/share/gnunet/config.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnunet-multicast $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnunet-social $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/gnunet-secushare/libexec/* $(1)/usr/lib/gnunet-secushare/libexec/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet-secushare/config.d/* $(1)/usr/share/gnunet-secushare/config.d
endef

define Package/gnunet-secushare-mysql/install
	$(INSTALL_DIR) $(1)/usr/lib/gnunet
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libgnunet_plugin_psycstore_mysql.so* $(1)/usr/lib/gnunet/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/gnunet-secushare-mysql.defaults $(1)/etc/uci-defaults/gnunet-secushare-mysql
endef

define Package/gnunet-secushare-pgsql/install
	$(INSTALL_DIR) $(1)/usr/lib/gnunet
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libgnunet_plugin_psycstore_postgres.so* $(1)/usr/lib/gnunet/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/gnunet-secushare-pgsql.defaults $(1)/etc/uci-defaults/gnunet-secushare-pgsql
endef

define Package/gnunet-secushare-sqlite/install
	$(INSTALL_DIR) $(1)/usr/lib/gnunet
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libgnunet_plugin_psycstore_sqlite.so* $(1)/usr/lib/gnunet/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/gnunet-secushare-sqlite.defaults $(1)/etc/uci-defaults/gnunet-secushare-sqlite
endef

$(eval $(call BuildPackage,gnunet-secushare))
$(eval $(call BuildPackage,gnunet-secushare-mysql))
$(eval $(call BuildPackage,gnunet-secushare-pgsql))
$(eval $(call BuildPackage,gnunet-secushare-sqlite))
