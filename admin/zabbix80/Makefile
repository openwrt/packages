#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zabbix80
# to fit APK package version syntax
PKG_VERSION:=8.0.0_beta2
PKG_SRC_NAME:=zabbix
PKG_SRC_VERSION:=8.0.0beta2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_SRC_NAME)-$(PKG_SRC_VERSION).tar.gz
PKG_SOURCE_URL:=https://cdn.zabbix.com/zabbix/sources/development/$(basename $(PKG_SRC_VERSION))/
PKG_HASH:=034fd030adeb08596f15702a94fa733a1d9a9822997e5dec2fe56594f9ca9a64
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_SRC_NAME)-$(PKG_SRC_VERSION)/

PKG_MAINTAINER:=Daniel F. Dickinson <dfdpublic@wildtechgarden.ca>
PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:zabbix:zabbix

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_CONFIG_DEPENDS:= \
  CONFIG_ZABBIX80_CURL \
  CONFIG_ZABBIX80_LDAP \
  CONFIG_ZABBIX80_MYSQL \
  CONFIG_ZABBIX80_NETSNMP \
  CONFIG_ZABBIX80_OPENSSL \
  CONFIG_ZABBIX80_POSTGRESQL \
  CONFIG_ZABBIX80_SQLITE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/zabbix80-agentd/config
	source "$(SOURCE)/Config.in"
endef

define Package/zabbix80-proxy/config
	choice
		prompt "Select Database Software for Zabbix"
		default ZABBIX80_POSTGRESQL

		config ZABBIX80_MYSQL
			bool "MySQL/MariaDB"

		config ZABBIX80_POSTGRESQL
			bool "PostgreSQL"

		config ZABBIX80_SQLITE
			bool "SQLite3"
	endchoice
endef

define Package/zabbix80-get/config
	config ZABBIX80_BUILD_SUPPORT_BIN
		bool
		depends on PACKAGE_zabbix80-agentd
		default y
		help
			This option exists to prevent trying to build get and/or sender when the
			of agent is not being built. In that case get and sender are not built by
			the Zabbix build system. This is not a dependency DEPENDS because the
			binaries do not require the agent to function.
endef

define Package/zabbix80/Default
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=Zabbix80
  TITLE:=Zabbix80 (BETA)
  URL:=https://www.zabbix.com/
endef

define Package/zabbix80/description/Default
  Zabbix is a software that monitors numerous parameters of a network and the
  health and integrity of servers, virtual machines, applications, services,
  databases, websites, the cloud and more. Zabbix offers excellent reporting and
  data visualization features based on the stored data.
  .
  Only one variant may be installed per binary (e.g. agent and agentd-basic cannot
  both be installed on the same system).
  .
  This is a pre-release beta of the next LTS series of Zabbix (8.0.x). It cannot
  be installed alongside the current LTS (7.0.x).
endef

define Package/zabbix80-basic/description/Default
  $(call Package/zabbix80/description/Default)
  .
  Provides only basic functionality with SSL/TLS.
endef

define Package/zabbix80-basic-sqlite/description/Default
  $(call Package/zabbix80/description/Default)
  .
  Provides only the basic functionality with SSL/TLS.
  Uses SQLite3 for the database.
endef

define Package/zabbix80-full/description/Default
  $(call Package/zabbix80/description/Default)
  .
  Provides the full functionality available in OpenWrt with OpenSSL.
  Includes NetSNMP, cURL, and OpenLDAP support.
  Requires a database server.
endef

define Package/zabbix80-agentd/Default
  $(call Package/zabbix80/Default)
  TITLE+= agentd
  DEPENDS+= \
    $(ICONV_DEPENDS) \
    +libevent2-pthreads \
    +libpcre2 \
    +zlib
  CONFLICTS:= \
    zabbix-agentd \
    zabbix-agentd-basic \
    zabbix-agentd-ssl \
    zabbix-agentd-openssl
  USERID:=zabbix-agent=53:zabbix-agent=53
endef

define Package/zabbix80-agentd
  $(call Package/zabbix80-agentd/Default)
  TITLE+= (full/with TLS)
  DEPENDS+= \
    +ZABBIX80_CURL:libcurl \
    +ZABBIX80_LDAP:libopenldap \
    +ZABBIX80_NETSNMP:libnetsnmp-ssl \
    +ZABBIX80_OPENSSL:libopenssl
  VARIANT:=full
  DEFAULT_VARIANT:=1
endef

define Package/zabbix80-agentd/description
  $(call Package/zabbix80-full/description/Default)
  .
  Provides 'Zabbix Agent'.
  .
  Note that 'Zabbix Agent' does not directly use the database, but sends data to
  a 'Zabbix Server' or a 'Zabbix Proxy', which writes to a database.
endef

define Package/zabbix80-agentd-basic
  $(call Package/zabbix80-agentd/Default)
  TITLE+= (basic/with TLS)
  DEPENDS += +libopenssl
  VARIANT:=basic
endef

define Package/zabbix80-agentd-basic/description
  $(call Package/zabbix80-basic/description/Default)
  .
  Provides 'Zabbix Agent'.
endef

define Package/zabbix80-get
  $(call Package/zabbix80/Default)
  TITLE+= get (with TLS)
  DEPENDS+= \
    @(ZABBIX80_BUILD_SUPPORT_BIN) \
    $(ICONV_DEPENDS) \
    +ZABBIX80_OPENSSL:libopenssl \
    +libpcre2 \
    +zlib
  CONFLICTS:= \
    zabbix-get \
    zabbix-get-ssl \
    zabbix-get-openssl
  VARIANT:=full
endef

define Package/zabbix80-get/description
  $(call Package/zabbix80-basic/description/Default)
  .
  Provides 'Zabbix Get'.
endef


define Package/zabbix80-server-or-proxy/Default
  $(call Package/zabbix80/Default)
  DEPENDS+= \
    $(ICONV_DEPENDS) \
    +fping \
    +libevent2 \
    +libevent2-pthreads \
    +libevent2-extra \
    +libpcre2 \
    +zlib
endef

define Package/zabbix80-proxy/Default
  $(call Package/zabbix80-server-or-proxy/Default)
  TITLE+= proxy
  CONFLICTS:= \
    zabbix-proxy \
    zabbix-proxy-basic-sqlite \
    zabbix-proxy-ssl \
    zabbix-proxy-openssl
  USERID:=zabbix-proxy=71:zabbix-proxy=71
endef

define Package/zabbix80-proxy
  $(call Package/zabbix80-proxy/Default)
  TITLE+= (full/with OpenSSL)
  DEPENDS+= \
    +ZABBIX80_CURL:libcurl \
    +ZABBIX80_LDAP:libopenldap \
    +ZABBIX80_MYSQL:libmariadbclient \
    +ZABBIX80_NETSNMP:libnetsnmp-ssl \
    +ZABBIX80_OPENSSL:libopenssl \
    +ZABBIX80_POSTGRESQL:libpq \
    +ZABBIX80_SQLITE:libsqlite3
  VARIANT:=full
  DEFAULT_VARIANT:=1
endef

define Package/zabbix80-proxy/description
  $(call Package/zabbix80-full/description/Default)
  .
  Provides 'Zabbix Proxy'.
endef

define Package/zabbix80-proxy-basic-sqlite
  $(call Package/zabbix80-proxy/Default)
  TITLE+= sqlite3 (basic/with TLS)
  DEPENDS+= \
    +libopenssl \
    +libsqlite3
  VARIANT:=basic
endef

define Package/zabbix80-proxy-basic-sqlite/description
  $(call Package/zabbix80-basic/description/Default)
  .
  Provides 'Zabbix Proxy' using sqlite3 for
  the database.
endef

define Package/zabbix80-sender
  $(call Package/zabbix80/Default)
  TITLE+= sender (with TLS)
  DEPENDS+= \
    @(ZABBIX80_BUILD_SUPPORT_BIN) \
    $(ICONV_DEPENDS) \
    +ZABBIX80_OPENSSL:libopenssl \
    +libpcre2 \
    +zlib
  CONFLICTS:= \
    zabbix-sender \
    zabbix-sender-ssl \
    zabbix-sender-openssl
  VARIANT:=full
endef

define Package/zabbix80-sender/description
  $(call Package/zabbix80-basic/description/Default)
  .
  Provides 'Zabbix Sender'.
endef

define Package/zabbix80-server
  $(call Package/zabbix80-server-or-proxy/Default)
  TITLE+= server (full/with OpenSSL)
  DEPENDS+= \
    @(!ZABBIX80_SQLITE) \
    +ZABBIX80_CURL:libcurl \
    +ZABBIX80_LDAP:libopenldap \
    +ZABBIX80_MYSQL:libmariadbclient \
    +ZABBIX80_OPENSSL:libopenssl \
    +ZABBIX80_NETSNMP:libnetsnmp-ssl \
    +ZABBIX80_POSTGRESQL:libpq
  CONFLICTS:= \
    zabbix-server \
    zabbix-server-ssl \
    zabbix-server-openssl
  USERID:=zabbix-server=70:zabbix-server=70
  VARIANT:=full
endef

define Package/zabbix80-server/description
  $(call Package/zabbix80-full/description/Default)
  .
  Provides 'Zabbix Server'.
endef

define Package/zabbix80-frontend-server
  $(call Package/zabbix80/Default)
  TITLE+= frontend server
  PKGARCH:=all
  DEPENDS+= \
    php8 \
    @(!ZABBIX80_SQLITE) \
    +ZABBIX80_MYSQL:php8-mod-mysqli \
    +ZABBIX80_POSTGRESQL:php8-mod-pgsql \
    +php8-cgi \
    +php8-mod-gd \
    +php8-mod-bcmath \
    +php8-mod-ctype \
    +php8-mod-curl \
    +php8-mod-filter \
    +php8-mod-gettext \
    +php8-mod-ldap \
    +php8-mod-mbstring \
    +php8-mod-openssl \
    +php8-mod-session \
    +php8-mod-simplexml \
    +php8-mod-sockets \
    +php8-mod-xmlreader \
    +php8-mod-xmlwriter
  CONFLICTS:= \
    zabbix-server-frontend \
    zabbix-frontend-server
  VARIANT:=no-configure
endef

define Package/zabbix80-frontend-server/description
  $(call Package/zabbix80/description/Default)
  .
  Provides the Web UI (frontend server) for Zabbix.
endef

ifneq ($(BUILD_VARIANT),no-configure)
CONFIGURE_ARGS+= \
  $(call autoconf_bool,CONFIG_IPV6,ipv6) \
  --disable-java \
  --with-libevent=$(STAGING_DIR)/usr/include \
  --with-libpcre2=$(STAGING_DIR)/usr/include \
  --with-zlib=$(STAGING_DIR)/usr/include
endif

ifeq ($(BUILD_VARIANT),basic)
CONFIGURE_ARGS+= \
  $(if $(CONFIG_PACKAGE_zabbix80-agentd-basic),--enable-agent,--disable-agent) \
  $(if $(CONFIG_PACKAGE_zabbix80-proxy-basic-sqlite),--enable-proxy --with-sqlite3,--disable-proxy) \
  --with-openssl="$(STAGING_DIR)/usr" \
  --disable-server
endif

ifeq ($(BUILD_VARIANT),full)

CONFIGURE_ARGS+= \
  $(if $(CONFIG_PACKAGE_zabbix80-agentd),--enable-agent,--disable-agent) \
  $(if $(CONFIG_PACKAGE_zabbix80-proxy),--enable-proxy,--disable-proxy) \
  $(if $(CONFIG_PACKAGE_zabbix80-server),--enable-server,--disable-server) \
  $(if $(CONFIG_ZABBIX80_LDAP),--with-ldap="$(STAGING_DIR)/usr",--with-ldap="no") \
  $(if $(CONFIG_ZABBIX80_MYSQL),--with-mysql,--with-mysql="no") \
  $(if $(CONFIG_ZABBIX80_NETSNMP),--with-net-snmp="$(STAGING_DIR)/usr",--with-net-snmp="no") \
  $(if $(CONFIG_ZABBIX80_OPENSSL),--with-openssl="$(STAGING_DIR)/usr",--with-openssl="no") \
  $(if $(CONFIG_ZABBIX80_POSTGRESQL),--with-postgresql,--with-postgresql="no") \
  $(if $(CONFIG_ZABBIX80_SQLITE),--with-sqlite3,--with-sqlite3="no") \
  $(if $(CONFIG_ZABBIX80_CURL),--with-libcurl,--with-libcurl="no") \
  --enable-year2038
endif

ifeq ($(BUILD_VARIANT),no-configure)

define Build/Configure
	true
endef
define Build/Compile
	true
endef
define Build/Install
	true
endef

endif

MAKE_FLAGS += ARCH="linux"

define Package/zabbix80/install/sbin
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/zabbix_$(2) $(1)/usr/sbin/
endef

define Package/zabbix80/install/bin
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/zabbix_$(2) $(1)/usr/bin/
endef

define Package/zabbix80/install/etc
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/zabbix_$(2).conf $(1)/etc/
endef

define Package/zabbix80/install/init.d
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/zabbix_$(2).init $(1)/etc/init.d/zabbix_$(2)
endef

define Package/zabbix80-agentd/conffiles
/etc/zabbix_agentd.conf
/etc/zabbix_agentd.conf.d/
/etc/config/zabbix_agentd
endef

define Package/zabbix80-agentd/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || (. /etc/uci-defaults/90_zabbix_agentd) && rm -f /etc/uci-defaults/90_zabbix_agentd
exit 0
endef

define Package/zabbix80-agentd/install
	$(INSTALL_DIR) $(1)/etc/zabbix_agentd.conf.d
	$(call Package/zabbix80/install/sbin,$(1),agentd)
	$(call Package/zabbix80/install/etc,$(1),agentd)
	$(call Package/zabbix80/install/init.d,$(1),agentd)
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/zabbix_agentd.config $(1)/etc/config/zabbix_agentd
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/zabbix_agentd.defaults $(1)/etc/uci-defaults/90_zabbix_agentd
endef

Package/zabbix80-agentd-basic/conffiles=$(call Package/zabbix80-agentd/conffiles)
Package/zabbix80-agentd-basic/postinst=$(call Package/zabbix80-agentd/postinst)

define Package/zabbix80-agentd-basic/install
	$(call Package/zabbix80-agentd/install,$(1))
endef

define Package/zabbix80-proxy/conffiles
/etc/zabbix_proxy.conf
/etc/zabbix_proxy.conf.d/
/etc/config/zabbix_proxy
endef

define Package/zabbix80-proxy/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || (. /etc/uci-defaults/90_zabbix_proxy) && rm -f /etc/uci-defaults/90_zabbix_proxy
exit 0
endef

define Package/zabbix80-proxy/install
	$(INSTALL_DIR) $(1)/etc/zabbix_proxy.conf.d
	$(call Package/zabbix80/install/sbin,$(1),proxy)
	$(call Package/zabbix80/install/etc,$(1),proxy)
	$(call Package/zabbix80/install/init.d,$(1),proxy)
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/zabbix_proxy.config $(1)/etc/config/zabbix_proxy
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/zabbix_proxy.defaults $(1)/etc/uci-defaults/90_zabbix_proxy
endef

Package/zabbix80-proxy-basic-sqlite/conffiles=$(call Package/zabbix80-proxy/conffiles)
Package/zabbix80-proxy-basic-sqlite/postinst=$(call Package/zabbix80-proxy/postinst)

define Package/zabbix80-proxy-basic-sqlite/install
	$(call Package/zabbix80-proxy/install,$(1))
endef

define Package/zabbix80-server/conffiles
/etc/zabbix_server.conf
/etc/zabbix_server.conf.d/
/etc/config/zabbix_server
endef

define Package/zabbix80-server/install
	$(INSTALL_DIR) $(1)/etc/zabbix_server.conf.d
	$(call Package/zabbix80/install/sbin,$(1),server)
	$(call Package/zabbix80/install/etc,$(1),server)
	$(call Package/zabbix80/install/init.d,$(1),server)
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/zabbix_server.config $(1)/etc/config/zabbix_server
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/zabbix_server.defaults $(1)/etc/uci-defaults/90_zabbix_server
endef

define Package/zabbix80-server/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || (. /etc/uci-defaults/90_zabbix_server) && rm -f /etc/uci-defaults/90_zabbix_server
exit 0
endef

define Package/zabbix80-get/install
	$(call Package/zabbix80/install/bin,$(1),get)
endef

define Package/zabbix80-sender/install
	$(call Package/zabbix80/install/bin,$(1),sender)
endef

define Package/zabbix80-frontend-server/install
	$(INSTALL_DIR) $(1)/www/zabbix
	$(CP) $(PKG_BUILD_DIR)/ui/* $(1)/www/zabbix
endef

# zabbix compiled variants (configured)
$(eval $(call BuildPackage,zabbix80-agentd))
$(eval $(call BuildPackage,zabbix80-agentd-basic))
$(eval $(call BuildPackage,zabbix80-get))
$(eval $(call BuildPackage,zabbix80-sender))
$(eval $(call BuildPackage,zabbix80-server))
$(eval $(call BuildPackage,zabbix80-proxy))
$(eval $(call BuildPackage,zabbix80-proxy-basic-sqlite))
# no-configure packages
$(eval $(call BuildPackage,zabbix80-frontend-server))
