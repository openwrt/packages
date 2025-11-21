#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rsyslog
PKG_VERSION:=8.2506.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:= \
	https://fossies.org/linux/misc \
	https://www.rsyslog.com/files/download/rsyslog
PKG_HASH:=6d6fd0257c95e756765d4d585a833d54dd3a0e5eeb8308b862a81b368a74bb7b

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:rsyslog:rsyslog

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/rsyslog
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Enhanced system logging and kernel message trapping daemons
  URL:=https://www.rsyslog.com/
  DEPENDS:= \
	+RSYSLOG_gssapi_krb5:krb5-libs +RSYSLOG_elasticsearch:libcurl \
	+RSYSLOG_libdbi:libdbi +libestr +libfastjson +RSYSLOG_gnutls:libgnutls \
	+RSYSLOG_mmdblookup:libmaxminddb +RSYSLOG_mysql:libmysqlclient \
	+RSYSLOG_omhttp:libcurl +RSYSLOG_openssl:libopenssl \
	+RSYSLOG_pgsql:libpq +libuuid +zlib
  MENU:=1
endef

define Package/rsyslog/conffiles
/etc/rsyslog.conf
endef

CONFIGURE_ARGS+= \
	--disable-libgcrypt \
	--disable-fmhttp \
	--disable-default-tests \
	--disable-libsystemd \
	$(if $(CONFIG_RSYSLOG_gssapi_krb5),--enable-gssapi-krb5) \
	$(if $(CONFIG_RSYSLOG_mysql),--enable-mysql) \
	$(if $(CONFIG_RSYSLOG_pgsql),--enable-pgsql) \
	$(if $(CONFIG_RSYSLOG_libdbi),--enable-libdbi) \
	$(if $(CONFIG_RSYSLOG_elasticsearch),--enable-elasticsearch) \
	$(if $(CONFIG_RSYSLOG_omhttp),--enable-omhttp) \
	$(if $(CONFIG_RSYSLOG_openssl),--enable-openssl) \
	$(if $(CONFIG_RSYSLOG_gnutls),--enable-gnutls) \
	$(if $(CONFIG_RSYSLOG_mail),--enable-mail) \
	$(if $(CONFIG_RSYSLOG_mmjsonparse),--enable-mmjsonparse) \
	$(if $(CONFIG_RSYSLOG_mmdblookup),--enable-mmdblookup) \
	$(if $(CONFIG_RSYSLOG_imfile),--enable-imfile)

define Package/rsyslog/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/rsyslogd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/lib/rsyslog
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/rsyslog/* $(1)/usr/lib/rsyslog/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/rsyslog.conf $(1)/etc
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/rsyslog.init $(1)/etc/init.d/rsyslog
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_CONF) ./files/20_rsyslog $(1)/etc/uci-defaults
endef

define Package/rsyslog/config
  source "$(SOURCE)/Config.in"
endef

$(eval $(call BuildPackage,rsyslog))
