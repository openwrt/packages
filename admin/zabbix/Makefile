#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# cspell:words TOPDIR DEBUGFS GNUTLS NOCONFIGURE SNMP agentd LIBNETSNMP
# cspell:words bcmath conffiles INSTROOT IPKG ctype endchoice fping killall
# cspell:words lcurl libevent libgnutls libiwinfo libmariadbclient libopenldap
# cspell:words libopenssl libpcre libpq libsqlite libubus lnetsnmp mbstring
# cspell:words mysqli nossl pgsql postinst pthreads ubus ubusd userparameters
# cspell:words wlan xmlreader xmlwriter

include $(TOPDIR)/rules.mk

PKG_NAME:=zabbix
PKG_VERSION:=7.0.22
PKG_RELEASE:=1

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

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/zabbix/Default
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=Zabbix
  TITLE:=Zabbix
  URL:=https://www.zabbix.com/
endef

define Package/zabbix-agent/Default
  $(call Package/zabbix/Default)
  USERID:=zabbix-agent=53:zabbix-agent=53
  TITLE+= agentd
  DEPENDS+=$(ICONV_DEPENDS) +libpcre2 +zlib \
    +libevent2-pthreads
  PROVIDES:=zabbix-agentd
  NOCONFIGURE:=false
endef

define Package/zabbix-server-proxy/Default
  $(call Package/zabbix/Default)
  USERID:=zabbix-server=70:zabbix-server=70
  DEPENDS+=$(ICONV_DEPENDS) +libpcre2 +zlib
  NOCONFIGURE:=false
endef

define Package/zabbix-agentd-tiny
  $(call Package/zabbix-agent/Default)
  TITLE+= (minimum/nossl)
  VARIANT:=tiny
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-agentd-openssl
  $(call Package/zabbix-agent/Default)
  TITLE+= (with OpenSSL)
  DEPENDS+= +libopenssl
  VARIANT:=openssl
endef

define Package/zabbix-agentd-gnutls
  $(call Package/zabbix-agent/Default)
  TITLE+= (with GnuTLS)
  DEPENDS+= +libgnutls
  VARIANT:=gnutls
endef

define Package/zabbix-agentd-full
  $(call Package/zabbix-agent/Default)
  TITLE+= (with OpenSSL, and cURL)
  DEPENDS+= +libopenssl +libcurl +libopenldap
  VARIANT:=full
endef

define Package/zabbix-agentd-full-gnutls
  $(call Package/zabbix-agent/Default)
  TITLE+= (with GnuTLS, and cURL)
  DEPENDS+= +libgnutls +libcurl-gnutls
  VARIANT:=full-gnutls
endef

define Package/zabbix-extra-mac80211
  $(call Package/zabbix/Default)
  TITLE+= discovery/userparameters for mac80211
  DEPENDS = +zabbix-agentd @PACKAGE_MAC80211_DEBUGFS @KERNEL_DEBUG_FS
  NOCONFIGURE:=true
endef

define Package/zabbix-extra-network
  $(call Package/zabbix/Default)
  TITLE+= discovery/userparameters for network
  DEPENDS = +zabbix-agentd +libubus-lua +lua
  NOCONFIGURE:=true
endef

define Package/zabbix-extra-wifi
  $(call Package/zabbix/Default)
  TITLE+= discovery/userparameters for wifi
  DEPENDS = +zabbix-agentd +libiwinfo-lua +libubus-lua +lua
  NOCONFIGURE:=true
endef

define Package/zabbix-sender/Default
  $(call Package/zabbix/Default)
  TITLE+= sender
  PROVIDES:=zabbix-sender
  DEPENDS+=$(ICONV_DEPENDS) +libpcre2 +zlib
  NOCONFIGURE:=false
endef

define Package/zabbix-sender-tiny
  $(call Package/zabbix-sender/Default)
  TITLE+= (minimum/nossl)
  VARIANT:=tiny
endef

define Package/zabbix-sender-openssl
  $(call Package/zabbix-sender/Default)
  TITLE+=(with OpenSSL)
  DEPENDS+= +libopenssl
  VARIANT:=openssl
endef

define Package/zabbix-sender-gnutls
  $(call Package/zabbix-sender/Default)
  TITLE+=(with GnuTLS)
  DEPENDS+= +libgnutls
  VARIANT:=gnutls
endef

define Package/zabbix-get/Default
  $(call Package/zabbix/Default)
  TITLE+= get
  PROVIDES:=zabbix-get
  DEPENDS+=$(ICONV_DEPENDS) +libpcre2 +zlib
  NOCONFIGURE:=false
endef

define Package/zabbix-get-tiny
  $(call Package/zabbix-get/Default)
  TITLE+= (minimum/nossl)
  VARIANT:=tiny
endef

define Package/zabbix-get-openssl
  $(call Package/zabbix-get/Default)
  TITLE+= (with OpenSSL)
  DEPENDS+= +libopenssl
  VARIANT:=openssl
endef

define Package/zabbix-get-gnutls
  $(call Package/zabbix-get/Default)
  TITLE+= (with GnuTLS)
  DEPENDS+= +libgnutls
  VARIANT:=gnutls
endef

define Package/zabbix-server/Default
  $(call Package/zabbix-server-proxy/Default)
 DEPENDS += \
    +libevent2 \
    +libevent2-pthreads \
    +libevent2-extra \
    +fping
  TITLE+= server
  PROVIDES:=zabbix-server
endef

define Package/zabbix-server-postgresql/Default
  $(call Package/zabbix-server/Default)
 DEPENDS += +libpq
  TITLE+= postgresql
endef

define Package/zabbix-server-small
  $(call Package/zabbix-server-postgresql/Default)
  TITLE+= (minimum/nossl)
  VARIANT:=small
endef

define Package/zabbix-server-openssl
  $(call Package/zabbix-server-postgresql/Default)
  TITLE+= (with OpenSSL)
  DEPENDS+= +libopenssl
  VARIANT:=openssl
endef

define Package/zabbix-server-gnutls
  $(call Package/zabbix-server-postgresql/Default)
  TITLE+= (with GnuTLS)
  DEPENDS+= +libgnutls
  VARIANT:=gnutls
endef

define Package/zabbix-server-full
  $(call Package/zabbix-server-postgresql/Default)
  TITLE+= (with OpenSSL, SNMP, and cURL)
  DEPENDS += \
    +libopenssl \
    +libnetsnmp-ssl \
    +libcurl \
    +libopenldap
  VARIANT:=full
endef

define Package/zabbix-server-full-gnutls
  $(call Package/zabbix-server-postgresql/Default)
  TITLE+= (with GnuTLS, SNMP, and cURL)
  DEPENDS += \
    +libgnutls \
    +libnetsnmp-nossl \
    +libcurl-gnutls
  VARIANT:=full-gnutls
endef

define Package/zabbix-server-mariadb/Default
  $(call Package/zabbix-server/Default)
 DEPENDS += +libmariadbclient
 TITLE+= mariadb
  PROVIDES:=zabbix-server
endef

define Package/zabbix-server-small-mariadb
  $(call Package/zabbix-server-mariadb/Default)
  TITLE+= (minimum/nossl)
  VARIANT:=small-mariadb
endef

define Package/zabbix-server-openssl-mariadb
  $(call Package/zabbix-server-mariadb/Default)
  TITLE+= (with OpenSSL)
  DEPENDS+= +libopenssl
  VARIANT:=openssl-mariadb
endef

define Package/zabbix-server-gnutls-mariadb
  $(call Package/zabbix-server-mariadb/Default)
  TITLE+= (with GnuTLS)
  DEPENDS+= +libgnutls
  VARIANT:=gnutls-mariadb
endef

define Package/zabbix-server-full-mariadb
  $(call Package/zabbix-server-mariadb/Default)
  TITLE+= (with OpenSSL, SNMP, and cURL)
  DEPENDS += \
    +libopenssl \
    +libnetsnmp-ssl \
    +libcurl \
    +libopenldap
  VARIANT:=full-mariadb
endef

define Package/zabbix-server-full-gnutls-mariadb
  $(call Package/zabbix-server-mariadb/Default)
  TITLE+= (with GnuTLS, SNMP, and cURL)
  DEPENDS += \
    +libgnutls \
    +libnetsnmp-nossl \
    +libcurl-gnutls
  VARIANT:=full-gnutls-mariadb
endef

define Package/zabbix-frontend-server
  $(call Package/zabbix/Default)
  TITLE+= frontend postgresql
  DEPENDS += @PACKAGE_php8 \
    +php8-cgi \
    +php8-mod-gd \
    +php8-mod-bcmath \
    +php8-mod-ctype \
    +php8-mod-filter \
    +php8-mod-xmlreader \
    +php8-mod-xmlwriter \
    +php8-mod-openssl \
    +php8-mod-session \
    +php8-mod-sockets \
    +php8-mod-mbstring \
    +php8-mod-gettext \
    +php8-mod-pgsql
  PROVIDES:=frontend-server
  VARIANT:=main
  DEFAULT_VARIANT:=1
  NOCONFIGURE:=true
endef

define Package/zabbix-frontend-server-mariadb
  $(call Package/zabbix/Default)
  TITLE+= frontend mariadb
  DEPENDS += @PACKAGE_php8 \
    +php8-cgi \
    +php8-mod-gd \
    +php8-mod-bcmath \
    +php8-mod-ctype \
    +php8-mod-filter \
    +php8-mod-xmlreader \
    +php8-mod-xmlwriter \
    +php8-mod-openssl \
    +php8-mod-session \
    +php8-mod-sockets \
    +php8-mod-mbstring \
    +php8-mod-gettext \
    +php8-mod-mysqli
  PROVIDES:=frontend-server
  VARIANT:=main-mariadb
  DEFAULT_VARIANT:=1
  NOCONFIGURE:=true
endef

define Package/zabbix-frontend-server-extra-auth
  $(call Package/zabbix/Default)
  TITLE+= frontend postgresql (extra auth)
  DEPENDS += @PACKAGE_php8 \
    +php8-cgi \
    +php8-mod-gd \
    +php8-mod-bcmath \
    +php8-mod-ctype \
    +php8-mod-filter \
    +php8-mod-xmlreader \
    +php8-mod-xmlwriter \
    +php8-mod-openssl \
    +php8-mod-session \
    +php8-mod-sockets \
    +php8-mod-mbstring \
    +php8-mod-gettext \
    +php8-mod-ldap \
    +php8-mod-curl \
    +php8-mod-pgsql
  PROVIDES:=frontend-server
  VARIANT:=extra-auth
  NOCONFIGURE:=true
endef

define Package/zabbix-frontend-server-extra-auth-mariadb
  $(call Package/zabbix/Default)
  TITLE+= frontend mariadb (extra auth)
  DEPENDS += @PACKAGE_php8 \
    +php8-cgi \
    +php8-mod-gd \
    +php8-mod-bcmath \
    +php8-mod-ctype \
    +php8-mod-filter \
    +php8-mod-xmlreader \
    +php8-mod-xmlwriter \
    +php8-mod-openssl \
    +php8-mod-session \
    +php8-mod-sockets \
    +php8-mod-mbstring \
    +php8-mod-gettext \
    +php8-mod-ldap \
    +php8-mod-curl \
    +php8-mod-mysqli
  PROVIDES:=frontend-server
  VARIANT:=extra-auth-mariadb
  NOCONFIGURE:=true
endef

define Package/zabbix-proxy/Default
  $(call Package/zabbix-proxy-server/Default)
  TITLE+= proxy
  PROVIDES:=zabbix-proxy
  DEPENDS += \
    +libevent2 \
    +libevent2-pthreads \
    +libevent2-extra \
    +fping
endef

define Package/zabbix-proxy-postgresql/Default
  $(call Package/zabbix-proxy/Default)
  TITLE+= postgresql
  DEPENDS += +libpq
endef

define Package/zabbix-proxy-mariadb/Default
  $(call Package/zabbix-proxy/Default)
  TITLE+= mariadb
  DEPENDS += +libmariadbclient
endef

define Package/zabbix-proxy-tiny
  $(call Package/zabbix-proxy/Default)
  TITLE+= sqlite3 (nossl)
  DEPENDS+= +libsqlite3
  VARIANT:=tiny
endef

define Package/zabbix-proxy-small
  $(call Package/zabbix-proxy-postgresql/Default)
  TITLE+= (nossl)
  VARIANT:=small
endef

define Package/zabbix-proxy-openssl
  $(call Package/zabbix-proxy-postgresql/Default)
  TITLE+= (with OpenSSL)
  DEPENDS += +libopenssl
  VARIANT:=openssl
endef

define Package/zabbix-proxy-gnutls
  $(call Package/zabbix-proxy-postgresql/Default)
  TITLE+= (with OpenSSL)
  DEPENDS += +gnutls
  VARIANT:=gnutls
endef

define Package/zabbix-proxy-full
  $(call Package/zabbix-proxy-postgresql/Default)
  TITLE+= (with OpenSSL, SNMP, and cURL)
  DEPENDS += \
    +libopenssl \
    +libnetsnmp-ssl \
    +libcurl \
    +libopenldap
  VARIANT:=full
endef

define Package/zabbix-proxy-full-gnutls
  $(call Package/zabbix-proxy-postgresql/Default)
  TITLE+= (with GnUTLS, SNMP, and cURL)
  DEPENDS += \
    +libgnutls \
    +libnetsnmp-nossl \
    +libcurl-gnutls
  VARIANT:=full-gnutls
endef

define Package/zabbix-proxy-small-mariadb
  $(call Package/zabbix-proxy-mariadb/Default)
  TITLE+= (nossl)
  VARIANT:=small-mariadb
endef

define Package/zabbix-proxy-openssl-mariadb
  $(call Package/zabbix-proxy-mariadb/Default)
  TITLE+= (with OpenSSL)
  DEPENDS += +libopenssl
  VARIANT:=openssl-mariadb
endef

define Package/zabbix-proxy-gnutls-mariadb
  $(call Package/zabbix-proxy-mariadb/Default)
  TITLE+= (with GnuTlS)
  DEPENDS += +libgnutls
  VARIANT:=gnutls-mariadb
endef

define Package/zabbix-proxy-full-mariadb
  $(call Package/zabbix-proxy-mariadb/Default)
  TITLE+= (with OpenSSL, SNMP, and cURL)
  DEPENDS += \
    +libopenssl \
    +libnetsnmp-ssl \
    +libcurl \
    +libopenldap
  VARIANT:=full-mariadb
endef

define Package/zabbix-proxy-full-gnutls-mariadb
  $(call Package/zabbix-proxy-mariadb/Default)
  TITLE+= (with GnuTLS, SNMP, and cURL)
  DEPENDS += \
    +libgnutls \
    +libnetsnmp-nossl \
    +libcurl-gnutls
  VARIANT:=full-gnutls-mariadb
endef

define Package/zabbix-extra-mac80211/description
An extra package for zabbix-agentd that adds a discovery rule for mac80211 wifi phy and many userparameters.
It contains an suid helper to allow zabbix-agentd to still run as zabbix user and not as root.
See https://openwrt.org/docs/guide-user/services/network_monitoring/zabbix for ready to use zabbix templates.
endef

define Package/zabbix-extra-network/description
An extra package for zabbix-agentd that adds a discovery rule for openwrt network interfaces.
The idea here is to discover only interfaces listed in /etc/config/network (discover br-lan and not eth0.1 and wlan0)
See https://openwrt.org/docs/guide-user/services/network_monitoring/zabbix for ready to use zabbix templates.
endef

define Package/zabbix-extra-wifi/description
An extra package for zabbix-agentd that adds a discovery rule for wifi interfaces and many userparameters.
As it uses libiwinfo, it works with all wifi devices supported by openwrt.
See https://openwrt.org/docs/guide-user/services/network_monitoring/zabbix for ready to use zabbix templates.
endef

# Only configure binaries which are compiled
ifneq ($(NOCONFIGURE),true)
CONFIGURE_ARGS += \
	--enable-agent \
	$(call autoconf_bool,CONFIG_IPV6,ipv6) \
	--disable-java \
	--with-libevent=$(STAGING_DIR)/usr/include \
	--with-libpcre2=$(STAGING_DIR)/usr/include \
	--with-zlib=$(STAGING_DIR)/usr/include

ifneq ($(filter openssl full openssl-mariadb full-mariadb,$(BUILD_VARIANT)),)
CONFIGURE_ARGS+= --with-openssl="$(STAGING_DIR)/usr"
endif

ifneq ($(filter gnutls full-gnutls gnutls-mariadb full-gnutls-mariadb,$(BUILD_VARIANT)),)
CONFIGURE_ARGS+= --with-gnutls="$(STAGING_DIR)/usr"
endif

ifeq ($(BUILD_VARIANT),tiny)
CONFIGURE_ARGS += --disable-server \
	$(if $(CONFIG_PACKAGE_zabbix-proxy-tiny), \
		--enable-proxy \
		--with-sqlite3=$(STAGING_DIR)/usr)
endif

ifneq ($(filter small openssl gnutls full full-gnutls,$(BUILD_VARIANT)),)
CONFIGURE_ARGS += --enable-server \
	--enable-proxy \
	--with-postgresql
endif

ifneq ($(filter small-mariadb openssl-mariadb gnutls-mariadb full-mariadb full-gnutls-mariadb,$(BUILD_VARIANT)),)
CONFIGURE_ARGS += --enable-server \
	--enable-proxy \
	--with-mysql
endif

ifneq ($(filter full full-mariadb,$(BUILD_VARIANT)),)
CONFIGURE_ARGS += --with-ldap="$(STAGING_DIR)/usr"
CONFIGURE_ARGS += --with-libcurl
CONFIGURE_ARGS += \
	ac_cv_path__libnetsnmp_config_bin="$(STAGING_DIR)/host/bin" \
	ac_cv_path__libnetsnmp_config_root="$(STAGING_DIR)/host/bin/net-snmp-config"
CONFIGURE_ARGS += --with-net-snmp
endif

ifneq ($(filter full-gnutls full-gnutls-mariadb,$(BUILD_VARIANT)),)
CONFIGURE_VARS += \
	LIBCURL_LIBS="-lcurl-gnutls" \
	LIBCURL_CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
	LIBCURL_LDFLAGS="-L$(STAGING_DIR)/usr/lib" \
	libcurl_cv_lib_curl_version=8.14.1 \
	ac_cv_path__libcurl_config="/bin/true" \
	libcurl_cv_lib_curl_usable=yes \
	libcurl_cv_lib_curl_version_ok=yes
CONFIGURE_ARGS += --with-libcurl="yes"

CONFIGURE_VARS += \
	LIBNETSNMP_LIBS="-lnetsnmp" \
	LIBNETSNMP_CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
	LIBNETSNMP_LDFLAGS="-L$(STAGING_DIR)/usr/lib" \
	ac_cv_path__libnetsnmp_config_bin="/bin" \
	ac_cv_path__libnetsnmp_config_root="/bin/true"
CONFIGURE_ARGS += --with-net-snmp="yes"
endif

else

ifndef CONFIG_PACKAGE_zabbix-extra-mac80211
define Build/Configure
	true
endef
define Build/Compile
	true
endef
endif

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

define Package/zabbix-agentd/conffiles/Default
/etc/zabbix_agentd.conf
endef
Package/zabbix-agentd-tiny/conffiles = $(Package/zabbix-agentd/conffiles/Default)
Package/zabbix-agentd-openssl/conffiles = $(Package/zabbix-agentd/conffiles/Default)
Package/zabbix-agentd-gnutls/conffiles = $(Package/zabbix-agentd/conffiles/Default)
Package/zabbix-agentd-full/conffiles = $(Package/zabbix-agentd/conffiles/Default)
Package/zabbix-agentd-full-gnutls/conffiles = $(Package/zabbix-agentd/conffiles/Default)

define Package/zabbix-server/conffiles/Default
/etc/zabbix_server.conf
/etc/config/zabbix_server
/etc/sysctl.d/90-zabbix-discovery-workers.conf
endef
Package/zabbix-server-small/conffiles = $(Package/zabbix-server/conffiles/Default)
Package/zabbix-server-openssl/conffiles = $(Package/zabbix-server/conffiles/Default)
Package/zabbix-server-gnutls/conffiles = $(Package/zabbix-server/conffiles/Default)
Package/zabbix-server-full/conffiles = $(Package/zabbix-server/conffiles/Default)
Package/zabbix-server-full-gnutls/conffiles = $(Package/zabbix-server/conffiles/Default)
Package/zabbix-server-small-mariadb/conffiles = $(Package/zabbix-server/conffiles/Default)
Package/zabbix-server-openssl-mariadb/conffiles = $(Package/zabbix-server/conffiles/Default)
Package/zabbix-server-gnutls-mariadb/conffiles = $(Package/zabbix-server/conffiles/Default)
Package/zabbix-server-full-mariadb/conffiles = $(Package/zabbix-server/conffiles/Default)
Package/zabbix-server-full-gnutls-mariadb/conffiles = $(Package/zabbix-server/conffiles/Default)

define Package/zabbix-proxy/conffiles/Default
/etc/zabbix_proxy.conf
endef
Package/zabbix-proxy-tiny/conffiles = $(Package/zabbix-proxy/conffiles/Default)
Package/zabbix-proxy-small/conffiles = $(Package/zabbix-proxy/conffiles/Default)
Package/zabbix-proxy-openssl/conffiles = $(Package/zabbix-proxy/conffiles/Default)
Package/zabbix-proxy-gnutls/conffiles = $(Package/zabbix-proxy/conffiles/Default)
Package/zabbix-proxy-full/conffiles = $(Package/zabbix-proxy/conffiles/Default)
Package/zabbix-proxy-full-gnutls/conffiles = $(Package/zabbix-proxy/conffiles/Default)
Package/zabbix-proxy-small-mariadb/conffiles = $(Package/zabbix-proxy/conffiles/Default)
Package/zabbix-proxy-openssl-mariadb/conffiles = $(Package/zabbix-proxy/conffiles/Default)
Package/zabbix-proxy-gnutls-mariadb/conffiles = $(Package/zabbix-proxy/conffiles/Default)
Package/zabbix-proxy-full-mariadb/conffiles = $(Package/zabbix-proxy/conffiles/Default)
Package/zabbix-proxy-full-gnutls-mariadb/conffiles = $(Package/zabbix-proxy/conffiles/Default)

ifdef CONFIG_PACKAGE_zabbix-extra-mac80211
define Build/Prepare/zabbix-extra-mac80211
	mkdir -p $(PKG_BUILD_DIR)/zabbix-extra-mac80211
	$(CP) ./files/zabbix_helper_mac80211.c $(PKG_BUILD_DIR)/zabbix-extra-mac80211/
endef

define Build/Compile/zabbix-extra-mac80211
	$(TARGET_CC) $(TARGET_CFLAGS) $(PKG_BUILD_DIR)/zabbix-extra-mac80211/zabbix_helper_mac80211.c -o $(PKG_BUILD_DIR)/zabbix-extra-mac80211/zabbix_helper_mac80211
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(call Build/Prepare/zabbix-extra-mac80211)
endef

define Build/Compile
	$(call Build/Compile/Default)
	$(call Build/Compile/zabbix-extra-mac80211)
endef
endif

define Package/zabbix-agentd/install/Default
	$(INSTALL_DIR) $(1)/etc/zabbix_agentd.conf.d
	$(call Package/zabbix/install/sbin,$(1),agentd)
	$(call Package/zabbix/install/etc,$(1),agentd)
	$(call Package/zabbix/install/init.d,$(1),agentd)
endef
Package/zabbix-agentd-tiny/install = $(Package/zabbix-agentd/install/Default)
Package/zabbix-agentd-openssl/install = $(Package/zabbix-agentd/install/Default)
Package/zabbix-agentd-gnutls/install = $(Package/zabbix-agentd/install/Default)
Package/zabbix-agentd-full/install = $(Package/zabbix-agentd/install/Default)
Package/zabbix-agentd-full-gnutls/install = $(Package/zabbix-agentd/install/Default)

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

define Package/zabbix-sender/install/Default
	$(call Package/zabbix/install/bin,$(1),sender)
endef
Package/zabbix-sender-tiny/install = $(Package/zabbix-sender/install/Default)
Package/zabbix-sender-openssl/install = $(Package/zabbix-sender/install/Default)
Package/zabbix-sender-gnutls/install = $(Package/zabbix-sender/install/Default)

define Package/zabbix-get/install/Default
	$(call Package/zabbix/install/bin,$(1),get)
endef
Package/zabbix-get-tiny/install = $(Package/zabbix-get/install/Default)
Package/zabbix-get-openssl/install = $(Package/zabbix-get/install/Default)
Package/zabbix-get-gnutls/install = $(Package/zabbix-get/install/Default)

define Package/zabbix-server/install/Default
	$(call Package/zabbix/install/sbin,$(1),server)
	$(call Package/zabbix/install/etc,$(1),server)
	$(call Package/zabbix/install/init.d,$(1),server)

	$(INSTALL_DIR) $(1)/etc/sysctl.d
	$(INSTALL_CONF) ./files/zabbix-discovery-workers.conf.sysctl $(1)/etc/sysctl.d/90-zabbix-discovery-workers.conf
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/zabbix_server.config $(1)/etc/config/zabbix_server
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/zabbix_server.defaults $(1)/etc/uci-defaults/90_zabbix_server
endef
Package/zabbix-server-small/install = $(Package/zabbix-server/install/Default)
Package/zabbix-server-openssl/install = $(Package/zabbix-server/install/Default)
Package/zabbix-server-gnutls/install = $(Package/zabbix-server/install/Default)
Package/zabbix-server-full/install = $(Package/zabbix-server/install/Default)
Package/zabbix-server-full-gnutls/install = $(Package/zabbix-server/install/Default)
Package/zabbix-server-small-mariadb/install = $(Package/zabbix-server/install/Default)
Package/zabbix-server-openssl-mariadb/install = $(Package/zabbix-server/install/Default)
Package/zabbix-server-gnutls-mariadb/install = $(Package/zabbix-server/install/Default)
Package/zabbix-server-full-mariadb/install = $(Package/zabbix-server/install/Default)
Package/zabbix-server-full-gnutls-mariadb/install = $(Package/zabbix-server/install/Default)

define Package/zabbix-server/postinst/Default
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || (. /etc/uci-defaults/90_zabbix_server) && rm -f /etc/uci-defaults/90_zabbix_server
exit 0
endef
Package/zabbix-server-small/postinst = $(Package/zabbix-server/postinst/Default)
Package/zabbix-server-openssl/postinst = $(Package/zabbix-server/postinst/Default)
Package/zabbix-server-gnutls/postinst = $(Package/zabbix-server/postinst/Default)
Package/zabbix-server-full/postinst = $(Package/zabbix-server/postinst/Default)
Package/zabbix-server-small-mariadb/postinst = $(Package/zabbix-server/postinst/Default)
Package/zabbix-server-openssl-mariadb/postinst = $(Package/zabbix-server/postinst/Default)
Package/zabbix-server-gnutls-mariadb/postinst = $(Package/zabbix-server/postinst/Default)
Package/zabbix-server-full-mariadb/postinst = $(Package/zabbix-server/postinst/Default)
Package/zabbix-server-full-gnutls-mariadb/postinst = $(Package/zabbix-server/postinst/Default)

define Package/zabbix-server-frontend/install/Default
	$(INSTALL_DIR) $(1)/www/zabbix
	$(CP) $(PKG_BUILD_DIR)/ui/* $(1)/www/zabbix
endef
Package/zabbix-server-frontend/install = $(Package/zabbix-server-frontend/install/Default)
Package/zabbix-server-frontend-extra-auth/install = $(Package/zabbix-server-frontend/install/Default)
Package/zabbix-server-frontend-mariadb/install = $(Package/zabbix-server-frontend/install/Default)
Package/zabbix-server-frontend-extra-auth-mariadb/install = $(Package/zabbix-server-frontend/install/Default)

define Package/zabbix-proxy/install/Default
	$(call Package/zabbix/install/sbin,$(1),proxy)
	$(call Package/zabbix/install/etc,$(1),proxy)
endef
Package/zabbix-proxy-tiny/install = $(Package/zabbix-proxy/install/Default)
Package/zabbix-proxy-small/install = $(Package/zabbix-proxy/install/Default)
Package/zabbix-proxy-openssl/install = $(Package/zabbix-proxy/install/Default)
Package/zabbix-proxy-openssl/install = $(Package/zabbix-proxy/install/Default)
Package/zabbix-proxy-full/install = $(Package/zabbix-proxy/install/Default)
Package/zabbix-proxy-full-gnutls/install = $(Package/zabbix-proxy/install/Default)
Package/zabbix-proxy-small-mariadb/install = $(Package/zabbix-proxy/install/Default)
Package/zabbix-proxy-openssl-mariadb/install = $(Package/zabbix-proxy/install/Default)
Package/zabbix-proxy-gnutls-mariadb/install = $(Package/zabbix-proxy/install/Default)
Package/zabbix-proxy-full-mariadb/install = $(Package/zabbix-proxy/install/Default)
Package/zabbix-proxy-full-gnutls-mariadb/install = $(Package/zabbix-proxy/install/Default)

$(eval $(call BuildPackage,zabbix-extra-mac80211))
$(eval $(call BuildPackage,zabbix-extra-network))
$(eval $(call BuildPackage,zabbix-extra-wifi))
$(eval $(call BuildPackage,zabbix-frontend-server))
$(eval $(call BuildPackage,zabbix-frontend-server-extra-auth))
$(eval $(call BuildPackage,zabbix-frontend-server-mariadb))
$(eval $(call BuildPackage,zabbix-frontend-server-extra-auth-mariadb))
$(eval $(call BuildPackage,zabbix-sender-tiny))
$(eval $(call BuildPackage,zabbix-sender-openssl))
$(eval $(call BuildPackage,zabbix-sender-gnutls))
$(eval $(call BuildPackage,zabbix-get-tiny))
$(eval $(call BuildPackage,zabbix-get-openssl))
$(eval $(call BuildPackage,zabbix-get-gnutls))
$(eval $(call BuildPackage,zabbix-agentd-tiny))
$(eval $(call BuildPackage,zabbix-agentd-openssl))
$(eval $(call BuildPackage,zabbix-agentd-gnutls))
$(eval $(call BuildPackage,zabbix-agentd-full))
$(eval $(call BuildPackage,zabbix-agentd-full-gnutls))
$(eval $(call BuildPackage,zabbix-proxy-tiny))
$(eval $(call BuildPackage,zabbix-proxy-small))
$(eval $(call BuildPackage,zabbix-proxy-openssl))
$(eval $(call BuildPackage,zabbix-proxy-gnutls))
$(eval $(call BuildPackage,zabbix-proxy-full))
$(eval $(call BuildPackage,zabbix-proxy-full-gnutls))
$(eval $(call BuildPackage,zabbix-server-small))
$(eval $(call BuildPackage,zabbix-server-openssl))
$(eval $(call BuildPackage,zabbix-server-gnutls))
$(eval $(call BuildPackage,zabbix-server-full))
$(eval $(call BuildPackage,zabbix-server-full-gnutls))
$(eval $(call BuildPackage,zabbix-proxy-small-mariadb))
$(eval $(call BuildPackage,zabbix-proxy-openssl-mariadb))
$(eval $(call BuildPackage,zabbix-proxy-gnutls-mariadb))
$(eval $(call BuildPackage,zabbix-proxy-full-mariadb))
$(eval $(call BuildPackage,zabbix-proxy-full-gnutls-mariadb))
$(eval $(call BuildPackage,zabbix-server-small-mariadb))
$(eval $(call BuildPackage,zabbix-server-openssl-mariadb))
$(eval $(call BuildPackage,zabbix-server-gnutls-mariadb))
$(eval $(call BuildPackage,zabbix-server-full-mariadb))
$(eval $(call BuildPackage,zabbix-server-full-gnutls-mariadb))
