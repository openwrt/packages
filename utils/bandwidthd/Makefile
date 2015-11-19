#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bandwidthd
PKG_VERSION:=2.0.1
PKG_RELEASE:=5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=@SF/bandwidthd
PKG_MD5SUM:=aa79aad7bd489fd2cae1f7dc086ca8b6

PKG_MAINTAINER:=Jean-Michel Lacroix <lacroix@lepine-lacroix.info>

PKG_LICENSE:=GPL-2.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/bandwidthd/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Bandwidthd
  URL:=http://bandwidthd.sourceforge.net/
endef

define Package/bandwidthd
$(call Package/bandwidthd/Default)
  TITLE += (without postgresql)
  VARIANT:=no-pgsql
  DEPENDS:=+libgd +libpcap
endef

define Package/bandwidthd-pgsql
$(call Package/bandwidthd/Default)
  TITLE += (with postgresql enabled)
  VARIANT:=pgsql
  DEPENDS:=+libgd +libpcap +libpq
endef

define Package/bandwidthd/description
  A bandwidthd tracking utility.
endef

define Package/bandwidthd-pgsql/description
$(call Package/bandwidthd/description)
With the ability to store in a postgresql database.
endef

define Package/bandwidthd/daemon
 This package contains bandwidthd a bandwith tracking utility.
endef

define Package/bandwidthd-pgsql/daemon
 This package contains bandwidthd a bandwith tracking utility.
endef

ifeq ($(BUILD_VARIANT),no-pgsql)
CONFIGURE_ARGS += \
	ac_cv_file__sw_lib=no \
	ac_cv_file__sw_include=no \
	ac_cv_file__usr_pkg_lib=no \
	ac_cv_file__usr_pkg_include=no \
	ac_cv_file__usr_local_pgsql_lib=no \
	ac_cv_file__usr_local_pgsql_include=no \
	ac_cv_lib_pq_PQconnectdb=no 
endif

ifeq ($(BUILD_VARIANT),pgsql)
CONFIGURE_ARGS += \
        ac_cv_file__sw_lib=no \
        ac_cv_file__sw_include=no \
        ac_cv_file__usr_pkg_lib=no \
        ac_cv_file__usr_pkg_include=no \
        ac_cv_file__usr_local_pgsql_lib=no \
        ac_cv_file__usr_local_pgsql_include=no
endif

EXTRA_CFLAGS+= $(TARGET_CPPFLAGS)
EXTRA_LDFLAGS+= $(TARGET_LDFLAGS) -Wl,-rpath-link,$(STAGING_DIR)/usr/lib

define Package/bandwidthd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bandwidthd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/bandwidthd.config $(1)/etc/config/bandwidthd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/bandwidthd.init $(1)/etc/init.d/bandwidthd
	$(INSTALL_DIR) $(1)/www
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/htdocs/legend.gif $(1)/www/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/htdocs/logo.gif $(1)/www/
endef

define Package/bandwidthd-pgsql/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bandwidthd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/bandwidthd-pgsql.config $(1)/etc/config/bandwidthd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/bandwidthd-pgsql.init $(1)/etc/init.d/bandwidthd
	$(INSTALL_DIR) $(1)/www/phphtdocs
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/htdocs/legend.gif $(1)/www/
	$(INSTALL_DATA) ./files/logo.gif $(1)/www/
	$(INSTALL_DIR) $(1)/usr/share/postgresql
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/schema.postgresql $(1)/usr/share/postgresql
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/phphtdocs/bd_pgsql_purge.sh $(1)/usr/share/postgresql
endef

define Package/bandwidthd/conffiles
/etc/config/bandwidthd
endef

define Package/bandwidthd-pgsql/conffiles
/etc/config/bandwidthd
endef

$(eval $(call BuildPackage,bandwidthd))
$(eval $(call BuildPackage,bandwidthd-pgsql))
