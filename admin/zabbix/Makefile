#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zabbix
PKG_VERSION:=7.0.22
PKG_RELEASE:=7

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://cdn.zabbix.com/zabbix/sources/stable/$(basename $(PKG_VERSION))/ \
	https://cdn.zabbix.com/zabbix/sources/oldstable/$(basename $(PKG_VERSION))/
PKG_HASH:=7a74794b2124607d8036be36cc104da056a2fb653811c84acbe29f3f6d97860a

PKG_MAINTAINER:=Daniel F. Dickinson <dfdpublic@wildtechgarden.ca>
PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:zabbix:zabbix

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_CONFIG_DEPENDS:= \
  CONFIG_ZABBIX_CURL \
  CONFIG_ZABBIX_CURL_GNUTLS \
  CONFIG_ZABBIX_GNUTLS \
  CONFIG_ZABBIX_LDAP \
  CONFIG_ZABBIX_MYSQL \
  CONFIG_ZABBIX_NETSNMP \
  CONFIG_ZABBIX_NETSNMP_NOSSL \
  CONFIG_ZABBIX_OPENSSL \
  CONFIG_ZABBIX_POSTGRESQL

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/zabbix-server-core-db-ssl/config
  source "$(SOURCE)/Config.in"
endef

define Package/zabbix/Default
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=Zabbix
  TITLE:=Zabbix
  URL:=https://www.zabbix.com/
endef

define Package/zabbix/description/Default
Zabbix is a software that monitors numerous parameters of a network and the
health and integrity of servers, virtual machines, applications, services,
databases, websites, the cloud and more. Zabbix offers excellent reporting and
data visualization features based on the stored data.
.
Different package variants (e.g. core-sqlite-nossl and full-db-ssl) for
different binaries (e.g. agent vs. server) may be installed alongside each
other. Only one variant may be installed per binary.
endef

define Package/zabbix-core-sqlite-nossl/description/Default
$(call Package/zabbix/description/Default)
.
Provides only the core functionality with no SSL/TLS.
endef

define Package/zabbix-core-sqlite-ssl/description/Default
$(call Package/zabbix/description/Default)
.
Provides only the core functionality with SSL/TLS.
endef

define Package/zabbix-core-db-nossl/description/Default
$(call Package/zabbix/description/Default)
.
Provides only the core functionality with no SSL/TLS.
Requires a database server.
endef

define Package/zabbix-core-db-ssl/description/Default
$(call Package/zabbix/description/Default)
.
Provides only the core functionality with SSL/TLS.
Requires a database server.
endef

define Package/zabbix-full-ssl-base/description/Default
$(call Package/zabbix/description/Default)
.
Provides the full functionality available in OpenWrt with OpenSSL.
Includes NetSNMP, cURL, and OpenLDAP support.
endef

define Package/zabbix-full-db-ssl/description/Default
$(call Package/zabbix-full-base/description/Default)
Requires a database server.
endef

define Package/zabbix-agentd/Default
  $(call Package/zabbix/Default)
  TITLE+= agentd
  DEPENDS:= \
    $(ICONV_DEPENDS) \
    +libevent2-pthreads \
    +libpcre2 \
    +zlib \
    +ZABBIX_CURL_GNUTLS:libcurl-gnutls \
    +ZABBIX_NETSNMP_NOSSL:libnetsnmp-nossl
  PROVIDES:=zabbix-agentd
  USERID:=zabbix-agent=53:zabbix-agent=53
endef

define Package/zabbix-agentd-core-sqlite-nossl
  $(call Package/zabbix-agentd/Default)
  TITLE+= (no TLS)
  DEPENDS+= \
    +ZABBIX_CURL_GNUTLS:libcurl-gnutls \
    +ZABBIX_NETSNMP_NOSSL:libnetsnmp-nossl
  PROVIDES+= zabbix-agentd-nossl
  VARIANT:=core-sqlite-nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-agentd-core-sqlite-nossl/description
$(call Package/zabbix-core-sqlite-nossl/description/Default)
.
Provides 'Zabbix Agent'.
.
Note that 'Zabbix Agent' does not directly use the database, but sends data to
a 'Zabbix Server' or a 'Zabbix Proxy', which writes to a database.
endef

define Package/zabbix-agentd-core-sqlite-ssl
  $(call Package/zabbix-agentd/Default)
  TITLE+= (with TLS)
  DEPENDS+= \
    +ZABBIX_CURL:libcurl \
    +ZABBIX_CURL_GNUTLS:libcurl-gnutls \
    +ZABBIX_GNUTLS:libgnutls \
    +ZABBIX_LDAP:libopenldap \
    +ZABBIX_NETSNMP:libnetsnmp-ssl \
    +ZABBIX_NETSNMP_NOSSL:libnetsnmp \
    +ZABBIX_OPENSSL:libopenssl
  PROVIDES+= zabbix-agentd-ssl
  VARIANT:=core-sqlite-ssl
endef

define Package/zabbix-agentd-core-sqlite-ssl/description
$(call Package/zabbix-core-sqlite-ssl/description/Default)
.
Provides 'Zabbix Agent'.
.
Note that 'Zabbix Agent' does not directly use the database, but sends data to
a 'Zabbix Server' or a 'Zabbix Proxy', which writes to a database.
endef

define Package/zabbix-agentd-full-sqlite-ssl
  $(call Package/zabbix-agentd/Default)
  TITLE+= (full/with OpenSSL)
  DEPENDS+= \
    +libcurl \
    +libnetsnmp-ssl \
    +libopenldap \
    +libopenssl
  PROVIDES+= zabbix-agentd-ssl
  VARIANT:=full-sqlite-ssl
endef

define Package/zabbix-agentd-full-sqlite-ssl/description
$(call Package/zabbix-full-ssl-base/description/Default)
.
Provides 'Zabbix Agent'.
.
Note that 'Zabbix Agent' does not directly use the database, but sends data to
a 'Zabbix Server' or a 'Zabbix Proxy', which writes to a database.
endef

define Package/zabbix-sender/Default
  $(call Package/zabbix/Default)
  TITLE+= sender
  DEPENDS:= \
    $(ICONV_DEPENDS) \
    +libpcre2 \
    +zlib
  PROVIDES:=zabbix-sender
endef

define Package/zabbix-sender-core-sqlite-nossl
  $(call Package/zabbix-sender/Default)
  TITLE+= (no TLS)
  PROVIDES+= zabbix-sender-nossl
  VARIANT:=core-sqlite-nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-sender-core-sqlite-nossl/description
$(call Package/zabbix-core-sqlite-nossl/description/Default)
.
Provides 'Zabbix Sender'.
.
Note that 'Zabbix Sender' does use the database, but is built during the same
compile as the other 'core-sqlite-nossl' packages.
endef

define Package/zabbix-sender-core-sqlite-ssl
  $(call Package/zabbix-sender/Default)
  TITLE+= (with TLS)
  DEPENDS+=\
    +ZABBIX_GNUTLS:libgnutls \
    +ZABBIX_OPENSSL:libopenssl
  VARIANT:=core-sqlite-ssl
endef

define Package/zabbix-sender-core-sqlite-ssl/description
$(call Package/zabbix-core-sqlite-ssl/description/Default)
.
Provides 'Zabbix Sender'.
.
Note that 'Zabbix Sender' does use the database, but is built during the same
compile as the other 'core-sqlite-ssl' packages.
endef

define Package/zabbix-get/Default
  $(call Package/zabbix/Default)
  TITLE+= get
  DEPENDS:= \
    $(ICONV_DEPENDS) \
    +libpcre2 \
    +zlib
  PROVIDES:=zabbix-get
endef

define Package/zabbix-get-core-sqlite-nossl
  $(call Package/zabbix-get/Default)
  TITLE+= (no TLS)
  PROVIDES+= zabbix-get-nossl
  VARIANT:=core-sqlite-nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-get-core-sqlite-nossl/description
$(call Package/zabbix-core-sqlite-nossl/description/Default)
.
Provides 'Zabbix Get'.
.
Note that 'Zabbix Get' does use the database, but is built during the same
compile as the other 'core-sqlite-nossl' packages.
endef

define Package/zabbix-get-core-sqlite-ssl
  $(call Package/zabbix-get/Default)
  TITLE+= (with TLS)
  DEPENDS+=\
    +ZABBIX_GNUTLS:libgnutls \
    +ZABBIX_OPENSSL:libopenssl
  VARIANT:=core-sqlite-ssl
endef

define Package/zabbix-get-core-sqlite-ssl/description
$(call Package/zabbix-core-sqlite-ssl/description/Default)
.
Provides 'Zabbix Get'.
.
Note that 'Zabbix Get' does use the database, but is built during the same
compile as the other 'core-sqlite-ssl' packages.
endef

define Package/zabbix-server-or-proxy/Default
  $(call Package/zabbix/Default)
  DEPENDS:= \
    $(ICONV_DEPENDS) \
    +fping \
    +libevent2 \
    +libevent2-pthreads \
    +libevent2-extra \
    +libpcre2 \
    +zlib
  USERID:=zabbix-server=70:zabbix-server=70
endef

define Package/zabbix-server/Default
  $(call Package/zabbix-server-or-proxy/Default)
  TITLE+= server
  DEPENDS+= \
    +ZABBIX_MYSQL:libmariadbclient \
    +ZABBIX_POSTGRESQL:libpq
  PROVIDES:=zabbix-server
endef

define Package/zabbix-server-core-db-nossl
  $(call Package/zabbix-server/Default)
  TITLE+= (no TLS)
  DEPENDS+= \
    +ZABBIX_CURL_GNUTLS:libcurl-gnutls \
    +ZABBIX_NETSNMP_NOSSL:libnetsnmp-nossl
  PROVIDES+= zabbix-server-nossl
  VARIANT:=core-db-nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-server-core-db-nossl/description
$(call Package/zabbix-core-db-nossl/description/Default)
.
Provides 'Zabbix Server'.
endef

define Package/zabbix-server-core-db-ssl
  $(call Package/zabbix-server/Default)
  TITLE+= (with TLS)
  DEPENDS+= \
    +ZABBIX_CURL:libcurl \
    +ZABBIX_CURL_GNUTLS:libcurl-gnutls \
    +ZABBIX_GNUTLS:libgnutls \
    +ZABBIX_LDAP:libopenldap \
    +ZABBIX_NETSNMP:libnetsnmp-ssl \
    +ZABBIX_NETSNMP_NOSSL:libnetsnmp \
    +ZABBIX_OPENSSL:libopenssl
  PROVIDES+= zabbix-server-ssl
  VARIANT:=core-db-ssl
endef

define Package/zabbix-server-core-db-ssl/description
$(call Package/zabbix-core-db-ssl/description/Default)
.
Provides 'Zabbix Server'.
endef

define Package/zabbix-server-full-db-ssl
  $(call Package/zabbix-server/Default)
  TITLE+= (full/with OpenSSL)
  DEPENDS+= \
    +libcurl \
    +libnetsnmp-ssl \
    +libopenldap \
    +libopenssl
  PROVIDES+= zabbix-server-ssl
  VARIANT:=full-db-ssl
endef

define Package/zabbix-server-full-db-ssl/description
$(call Package/zabbix-full-db-ssl/description/Default)
.
Provides 'Zabbix Server'.
endef

define Package/zabbix-proxy/Default
  $(call Package/zabbix-server-or-proxy/Default)
  TITLE+= proxy
  PROVIDES:=zabbix-proxy
endef

define Package/zabbix-proxy-core-sqlite-nossl
  $(call Package/zabbix-proxy/Default)
  TITLE+= sqlite3 (no TLS)
  DEPENDS+= \
    +ZABBIX_CURL_GNUTLS:libcurl-gnutls \
    +ZABBIX_NETSNMP_NOSSL:libnetsnmp-nossl \
    +libsqlite3
  PROVIDES += zabbix-proxy-nossl
  VARIANT:=core-sqlite-nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-proxy-core-sqlite-nossl/description
$(call Package/zabbix-core-sqlite-nossl/description/Default)
.
Provides 'Zabbix Proxy' using sqlite3 for
the database.
endef

define Package/zabbix-proxy-core-sqlite-ssl
  $(call Package/zabbix-proxy/Default)
  TITLE+= sqlite3 (with TLS)
  DEPENDS+= \
    +ZABBIX_CURL_GNUTLS:libcurl-gnutls \
    +ZABBIX_GNUTLS:libgnutls \
    +ZABBIX_NETSNMP_NOSSL:libnetsnmp-nossl \
    +ZABBIX_OPENSSL:libopenssl \
    +libsqlite3
  PROVIDES += zabbix-proxy-ssl
  VARIANT:=core-sqlite-ssl
endef

define Package/zabbix-proxy-core-sqlite-ssl/description
$(call Package/zabbix-core-sqlite-ssl/description/Default)
.
Provides 'Zabbix Proxy' using sqlite3 for
the database.
endef

define Package/zabbix-proxy-full-sqlite-ssl
  $(call Package/zabbix-proxy/Default)
  TITLE+= sqlite3 (full/with OpenSSL)
  DEPENDS+= \
    +libcurl \
    +libnetsnmp-ssl \
    +libopenldap \
    +libopenssl \
    +libsqlite3
  PROVIDES+= zabbix-proxy-ssl
  VARIANT:=full-sqlite-ssl
endef

define Package/zabbix-proxy-full-sqlite-ssl/description
$(call Package/zabbix-full-ssl-base/description/Default)
.
Provides 'Zabbix Proxy' using sqlite3 for
the database.
endef

define Package/zabbix-proxy-sql-server/Default
  $(call Package/zabbix-proxy/Default)
  TITLE+= sql
  DEPENDS+= \
    +ZABBIX_MYSQL:libmariadbclient \
    +ZABBIX_POSTGRESQL:libpq
endef

define Package/zabbix-proxy-core-db-nossl
  $(call Package/zabbix-proxy-sql-server/Default)
  TITLE+= (no TLS)
  DEPENDS+= \
    +ZABBIX_CURL_GNUTLS:libcurl-gnutls \
    +ZABBIX_NETSNMP_NOSSL:libnetsnmp-nossl
  PROVIDES+= zabbix-proxy-nossl
  VARIANT:=core-db-nossl
endef

define Package/zabbix-proxy-core-db-nossl/description
$(call Package/zabbix-core-db-nossl/description/Default)
.
Provides 'Zabbix Proxy'.
endef

define Package/zabbix-proxy-core-db-ssl
  $(call Package/zabbix-proxy-sql-server/Default)
  TITLE+= (with TLS)
  DEPENDS+= \
    +ZABBIX_CURL:libcurl \
    +ZABBIX_CURL_GNUTLS:libcurl-gnutls \
    +ZABBIX_GNUTLS:libgnutls \
    +ZABBIX_LDAP:libopenldap \
    +ZABBIX_NETSNMP:libnetsnmp-ssl \
    +ZABBIX_NETSNMP_NOSSL:libnetsnmp \
    +ZABBIX_OPENSSL:libopenssl
  PROVIDES+= zabbix-proxy-ssl
  VARIANT:=core-db-ssl
endef

define Package/zabbix-proxy-core-db-ssl/description
$(call Package/zabbix-core-db-ssl/description/Default)
.
Provides 'Zabbix Proxy'.
endef


define Package/zabbix-proxy-full-db-ssl
  $(call Package/zabbix-proxy-sql-server/Default)
  TITLE+= (full/with OpenSSL)
  DEPENDS+= \
    +libcurl \
    +libnetsnmp-ssl \
    +libopenldap \
    +libopenssl
  PROVIDES+= zabbix-proxy-ssl
  VARIANT:=full-db-ssl
endef

define Package/zabbix-proxy-full-db-ssl/description
$(call Package/zabbix-full-db-ssl/description/Default)
.
Provides 'Zabbix Proxy'.
endef

define Package/zabbix-extra-mac80211
  $(call Package/zabbix/Default)
  TITLE+= discovery/userparameters for mac80211
  DEPENDS:= \
    @KERNEL_DEBUG_FS \
    @PACKAGE_MAC80211_DEBUGFS \
    +zabbix-agentd
  VARIANT:=no-configure
endef

define Package/zabbix-extra-mac80211/description
An extra package for zabbix-agentd that adds a discovery rule for mac80211 wifi phy and many userparameters.
It contains an suid helper to allow zabbix-agentd to still run as zabbix user and not as root.
See https://openwrt.org/docs/guide-user/services/network_monitoring/zabbix for ready to use zabbix templates.
endef

define Package/zabbix-extra-network
  $(call Package/zabbix/Default)
  TITLE+= discovery/userparameters for network
  PKGARCH:=all
  DEPENDS:= \
    +libubus-lua \
    +lua \
    +zabbix-agentd
  VARIANT:=no-configure
endef

define Package/zabbix-extra-network/description
An extra package for zabbix-agentd that adds a discovery rule for openwrt network interfaces.
The idea here is to discover only interfaces listed in /etc/config/network (discover br-lan and not eth0.1 and wlan0)
See https://openwrt.org/docs/guide-user/services/network_monitoring/zabbix for ready to use zabbix templates.
endef

define Package/zabbix-extra-wifi
  $(call Package/zabbix/Default)
  TITLE+= discovery/userparameters for wifi
  PKGARCH:=all
  DEPENDS:= \
    +libiwinfo-lua \
    +libubus-lua +lua \
    +zabbix-agentd
  VARIANT:=no-configure
endef

define Package/zabbix-extra-wifi/description
An extra package for zabbix-agentd that adds a discovery rule for wifi interfaces and many userparameters.
As it uses libiwinfo, it works with all wifi devices supported by openwrt.
See https://openwrt.org/docs/guide-user/services/network_monitoring/zabbix for ready to use zabbix templates.
endef

define Package/zabbix-frontend-server-full-db-ssl
  $(call Package/zabbix/Default)
  TITLE+= frontend server
  PKGARCH:=all
  DEPENDS:= \
    php8 \
    +ZABBIX_MYSQL:php8-mod-mysqli \
    +ZABBIX_POSTGRESQL:php8-mod-pgsql \
    +php8-cgi \
    +php8-mod-gd \
    +php8-mod-bcmath \
    +php8-mod-ctype \
    +php8-mod-filter \
    +php8-mod-gettext \
    +php8-mod-mbstring \
    +php8-mod-openssl \
    +php8-mod-session \
    +php8-mod-sockets \
    +php8-mod-xmlreader \
    +php8-mod-xmlwriter
  PROVIDES:=zabbix-server-frontend zabbix-frontend-server
  VARIANT:=no-configure
endef

define Package/zabbix-frontend-server-full-db-ssl/description
$(call Package/zabbix/description/Default)
.
Provides the Web UI (frontend server) for Zabbix.
endef

ifneq ($(BUILD_VARIANT),no-configure)

CONFIGURE_ARGS+= \
	$(call autoconf_bool,CONFIG_IPV6,ipv6) \
	--disable-java \
	--enable-agent \
	--enable-proxy \
	--with-libevent=$(STAGING_DIR)/usr/include \
	--with-libpcre2=$(STAGING_DIR)/usr/include \
	--with-zlib=$(STAGING_DIR)/usr/include

ifneq ($(filter full-db-ssl full-sqlite-ssl,$(BUILD_VARIANT)),)
CONFIGURE_ARGS += \
  ac_cv_path__libnetsnmp_config_bin="$(STAGING_DIR)/host/bin" \
  ac_cv_path__libnetsnmp_config_root="$(STAGING_DIR)/host/bin/net-snmp-config" \
  --with-ldap="$(STAGING_DIR)/usr" \
  --with-net-snmp \
  --with-libcurl \
  --with-openssl="$(STAGING_DIR)/usr"

else

ifeq ($(CONFIG_ZABBIX_CURL),y)
CONFIGURE_ARGS += \
  --with-libcurl
endif

ifeq ($(CONFIG_ZABBIX_CURL_GNUTLS),y)
CONFIGURE_VARS += \
  ac_cv_path__libcurl_config="/bin/true" \
  LIBCURL_CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
  LIBCURL_LDFLAGS="-L$(STAGING_DIR)/usr/lib" \
  LIBCURL_LIBS="-lcurl-gnutls" \
  libcurl_cv_lib_curl_usable=yes \
  libcurl_cv_lib_curl_version=8.14.1 \
  libcurl_cv_lib_curl_version_ok=yes
CONFIGURE_ARGS += --with-libcurl="yes"
endif

ifeq ($(CONFIG_ZABBIX_LDAP),y)
CONFIGURE_ARGS += \
  --with-ldap="$(STAGING_DIR)/usr"
endif

ifneq ($(CONFIG_ZABBIX_NETSNMP)$(CONFIG_ZABBIX_NETSNMP_NOSSL),)
CONFIGURE_ARGS += \
  ac_cv_path__libnetsnmp_config_bin="$(STAGING_DIR)/host/bin" \
  ac_cv_path__libnetsnmp_config_root="$(STAGING_DIR)/host/bin/net-snmp-config" \
  --with-net-snmp
endif

endif

ifneq ($(filter core-sqlite-ssl core-db-ssl,$(BUILD_VARIANT)),)
CONFIGURE_ARGS += \
  $(if $(CONFIG_ZABBIX_GNUTLS),--with-gnutls="$(STAGING_DIR)/usr") \
  $(if $(CONFIG_ZABBIX_OPENSSL),--with-openssl="$(STAGING_DIR)/usr")
endif

ifneq ($(filter core-sqlite-nossl core-sqlite-ssl full-sqlite-ssl,$(BUILD_VARIANT)),)
CONFIGURE_ARGS+= \
	--disable-server \
	--with-sqlite3=$(STAGING_DIR)/usr
endif

ifneq ($(filter core-db-nossl core-db-ssl full-db-ssl,$(BUILD_VARIANT)),)
CONFIGURE_ARGS+= \
	--enable-server \
	$(if $(CONFIG_ZABBIX_MYSQL),--with-mysql) \
	$(if $(CONFIG_ZABBIX_POSTGRESQL),--with-postgresql)
endif

ifneq ($(filter core-sqlite-nossl core-db-nossl,$(BUILD_VARIANT)),)
CONFIGURE_ARGS += --with-openssl="no" --with-gnutls="no"
endif

else

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

ifdef CONFIG_PACKAGE_zabbix-extra-mac80211
define Build/Prepare
	$(call Build/Prepare/Default)
	mkdir -p $(PKG_BUILD_DIR)/zabbix-extra-mac80211
	$(CP) ./files/zabbix_helper_mac80211.c $(PKG_BUILD_DIR)/zabbix-extra-mac80211/
endef

define Build/Configure
	$(call Build/Configure/Default)
endef

# We use spaces for continued lines so that is if continuation does not parse
# properly we will get a hard error instead of subtle failure.
define Build/Compile
	$(call Build/Compile/Default)
	$(TARGET_CC) $(TARGET_CFLAGS) \
    $(PKG_BUILD_DIR)/zabbix-extra-mac80211/zabbix_helper_mac80211.c \
    -o $(PKG_BUILD_DIR)/zabbix-extra-mac80211/zabbix_helper_mac80211
endef
endif

MAKE_FLAGS += ARCH="linux"

define Package/zabbix/install/sbin
	$(INSTALL_DIR) \
		$(1)/usr/sbin

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/sbin/zabbix_$(2) \
		$(1)/usr/sbin/
endef

define Package/zabbix/install/bin
	$(INSTALL_DIR) \
		$(1)/usr/bin

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/zabbix_$(2) \
		$(1)/usr/bin/
endef

define Package/zabbix/install/etc
	$(INSTALL_DIR) \
		$(1)/etc

	$(INSTALL_CONF) \
		$(PKG_INSTALL_DIR)/etc/zabbix_$(2).conf \
		$(1)/etc/
endef

define Package/zabbix/install/init.d
	$(INSTALL_DIR) \
		$(1)/etc/init.d

	$(INSTALL_BIN) \
		./files/zabbix_$(2).init \
		$(1)/etc/init.d/zabbix_$(2)
endef

define Package/zabbix/install/zabbix.conf.d
	$(INSTALL_DIR) \
		$(1)/etc/zabbix_agentd.conf.d

	$(INSTALL_BIN) \
		./files/$(2) \
		$(1)/etc/zabbix_agentd.conf.d/$(2)
endef

# Due to nested defines, eval, and call, the extra spaces for the nested define,
# and tabs for the part that actually executes in a shell, is essential.
define Package/zabbix-daemon/files
        define Package/zabbix-$(1)-$(2)/conffiles
  /etc/zabbix_$(1).conf
  $(3)
        endef
        define Package/zabbix-$(1)-$(2)/install
		$(INSTALL_DIR) $$(1)/etc/zabbix_$(1).conf.d
		$(call Package/zabbix/install/sbin,$$(1),$(1))
		$(4)
        endef
endef

define Package/zabbix-server/conffiles-extra
/etc/config/zabbix_server
/etc/sysctl.d/90-zabbix-discovery-workers.conf
endef

define Package/zabbix-agentd/install-extra
	$(call Package/zabbix/install/etc,$$(1),agentd)
	$(call Package/zabbix/install/init.d,$$(1),agentd)
endef

define Package/zabbix-server/install-extra
	$(call Package/zabbix/install/etc,$$(1),server)
	$(call Package/zabbix/install/init.d,$$(1),server)
	$(INSTALL_DIR) $$(1)/etc/sysctl.d
	$(INSTALL_CONF) ./files/zabbix-discovery-workers.conf.sysctl \
    $$(1)/etc/sysctl.d/90-zabbix-discovery-workers.conf
	$(INSTALL_DIR) $$(1)/etc/config
	$(INSTALL_CONF) ./files/zabbix_server.config $$(1)/etc/config/zabbix_server
	$(INSTALL_DIR) $$(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/zabbix_server.defaults $$(1)/etc/uci-defaults/90_zabbix_server
endef

$(foreach zvariant,core-sqlite-nossl core-sqlite-ssl full-sqlite-ssl,$(eval $(call Package/zabbix-daemon/files,agentd,$(zvariant),,$(call Package/zabbix-agentd/install-extra))))
$(foreach zvariant,core-sqlite-nossl core-sqlite-ssl core-db-nossl core-db-ssl full-sqlite3-ssl full-db-ssl,$(eval $(call Package/zabbix-daemon/files,proxy,$(zvariant))))
$(foreach zvariant,core-db-nossl core-db-ssl full-db-ssl,$(eval $(call Package/zabbix-daemon/files,server,$(zvariant),$(call Package/zabbix-server/conffiles-extra),$(call Package/zabbix-server/install-extra))))

# Due to nested defines, eval, and call, the extra spaces for the nested define
# is essential.
define Package/zabbix-server/postinst/Default
        define Package/zabbix-server-$(1)/postinst
  #!/bin/sh
  [ -n "$$$${IPKG_INSTROOT}" ] || (. /etc/uci-defaults/90_zabbix_server) && rm -f /etc/uci-defaults/90_zabbix_server
  exit 0
         endef
endef

$(foreach zvariant,core-db-nossl core-db-ssl full-db-ssl,$(eval $(call Package/zabbix-server/postinst/Default,$(zvariant))))

define Package/zabbix-program/files
        define Package/zabbix-$(1)-$(2)/install
		$(call Package/zabbix/install/bin,$$(1),$(1))
        endef
endef

$(foreach zvariant,core-sqlite-nossl core-sqlite-ssl,$(eval $(call Package/zabbix-program/files,get,$(zvariant))))
$(foreach zvariant,core-sqlite-nossl core-sqlite-ssl,$(eval $(call Package/zabbix-program/files,sender,$(zvariant))))

define Package/zabbix-extra-mac80211/install
	$(call Package/zabbix/install/zabbix.conf.d,$(1),mac80211)
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/zabbix-extra-mac80211/zabbix_helper_mac80211 $(1)/usr/bin/
	chmod 4755 $(1)/usr/bin/zabbix_helper_mac80211
endef

define Package/zabbix-extra-network/install
	$(call Package/zabbix/install/zabbix.conf.d,$(1),network)
	$(INSTALL_DIR) $(1)/usr/share/acl.d
	$(INSTALL_DATA) ./files/zabbix-network-ubus-acl.json $(1)/usr/share/acl.d/zabbix-network.json
endef

define Package/zabbix-extra-network/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	killall -s HUP ubusd
fi
endef

define Package/zabbix-extra-wifi/install
	$(call Package/zabbix/install/zabbix.conf.d,$(1),wifi)
	$(INSTALL_DIR) $(1)/usr/share/acl.d
	$(INSTALL_DATA) ./files/zabbix-wifi-ubus-acl.json $(1)/usr/share/acl.d/zabbix-wifi.json
endef

define Package/zabbix-extra-wifi/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	killall -s HUP ubusd
fi
endef

define Package/zabbix-frontend-server-full-db-ssl/install
	$(INSTALL_DIR) $(1)/www/zabbix
	$(CP) $(PKG_BUILD_DIR)/ui/* $(1)/www/zabbix
endef

# zabbix compiled variants (configured)
$(eval $(call BuildPackage,zabbix-agentd-core-sqlite-nossl))
$(eval $(call BuildPackage,zabbix-agentd-core-sqlite-ssl))
$(eval $(call BuildPackage,zabbix-agentd-full-sqlite-ssl))
$(eval $(call BuildPackage,zabbix-get-core-sqlite-nossl))
$(eval $(call BuildPackage,zabbix-get-core-sqlite-ssl))
$(eval $(call BuildPackage,zabbix-sender-core-sqlite-nossl))
$(eval $(call BuildPackage,zabbix-sender-core-sqlite-ssl))
$(eval $(call BuildPackage,zabbix-proxy-core-db-nossl))
$(eval $(call BuildPackage,zabbix-proxy-core-db-ssl))
$(eval $(call BuildPackage,zabbix-proxy-core-sqlite-nossl))
$(eval $(call BuildPackage,zabbix-proxy-core-sqlite-ssl))
$(eval $(call BuildPackage,zabbix-proxy-full-db-ssl))
$(eval $(call BuildPackage,zabbix-proxy-full-sqlite-ssl))
$(eval $(call BuildPackage,zabbix-server-core-db-nossl))
$(eval $(call BuildPackage,zabbix-server-core-db-ssl))
$(eval $(call BuildPackage,zabbix-server-full-db-ssl))
# no-configure packages
$(eval $(call BuildPackage,zabbix-extra-mac80211))
$(eval $(call BuildPackage,zabbix-extra-network))
$(eval $(call BuildPackage,zabbix-extra-wifi))
$(eval $(call BuildPackage,zabbix-frontend-server-full-db-ssl))
