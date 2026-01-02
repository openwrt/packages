#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

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

PKG_CONFIG_DEPENDS:= \
  CONFIG_ZABBIX_MYSQL \
  CONFIG_ZABBIX_POSTGRESQL \
  CONFIG_ZABBIX_PROXY_MYSQL \
  CONFIG_ZABBIX_PROXY_POSTGRESQL \
  CONFIG_ZABBIX_OPENSSL \
  CONFIG_ZABBIX_GNUTLS

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/zabbix-server-ssl/config
comment "Zabbix Database Software"
choice
        prompt "Selected Database Software"
        default ZABBIX_POSTGRESQL

        config ZABBIX_MYSQL
                bool "MySQL/MariaDB"

        config ZABBIX_POSTGRESQL
                bool "PostgreSQL"
endchoice
endef

define Package/zabbix-agentd-ssl/config
comment "Zabbix SSL Library"
choice
        prompt "Selected SSL Library"
        default ZABBIX_OPENSSL

        config ZABBIX_GNUTLS
                bool "GnuTLS"

        config ZABBIX_OPENSSL
                bool "OpenSSL"
endchoice
endef

define Package/zabbix/Default
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=Zabbix
  TITLE:=Zabbix
  URL:=https://www.zabbix.com/
  USERID:=zabbix=53:zabbix=53
  DEPENDS+=$(ICONV_DEPENDS) +libpcre2 +zlib
endef

define Package/zabbix-agentd-tiny
  $(call Package/zabbix/Default)
  TITLE+= agentd (minimum/nossl)
  DEPENDS+= +libevent2-pthreads
  PROVIDES:=zabbix-agentd
  VARIANT:=tiny
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-agentd-ssl
  $(call Package/zabbix/Default)
  TITLE+= agentd (with SSL)
  DEPENDS+= +libevent2-pthreads \
    +ZABBIX_OPENSSL:libopenssl +ZABBIX_GNUTLS:libgnutls
  PROVIDES:=zabbix-agentd
  VARIANT:=ssl
endef

define Package/zabbix-agentd-full
  $(call Package/zabbix/Default)
  TITLE+= agentd (with SSL, and cURL)
  DEPENDS+= +libevent2-pthreads \
    +ZABBIX_OPENSSL:libopenssl \
    +ZABBIX_OPENSSL:libcurl \
    +ZABBIX_GNUTLS:libgnutls \
    +ZABBIX_GNUTLS:libcurl-gnutls \
    +libopenldap
  PROVIDES:=zabbix-agentd
  VARIANT:=full
endef

define Package/zabbix-extra-mac80211
  $(call Package/zabbix/Default)
  TITLE+= discovery/userparameters for mac80211
  DEPENDS = +zabbix-agentd @PACKAGE_MAC80211_DEBUGFS @KERNEL_DEBUG_FS
endef

define Package/zabbix-extra-network
  $(call Package/zabbix/Default)
  TITLE+= discovery/userparameters for network
  DEPENDS = +zabbix-agentd +libubus-lua +lua
endef

define Package/zabbix-extra-wifi
  $(call Package/zabbix/Default)
  TITLE+= discovery/userparameters for wifi
  DEPENDS = +zabbix-agentd +libiwinfo-lua +libubus-lua +lua
endef

define Package/zabbix-sender-tiny
  $(call Package/zabbix/Default)
  TITLE+= sender (minimum/nossl)
  PROVIDES:=zabbix-sender
  VARIANT:=tiny
endef

define Package/zabbix-sender-ssl
  $(call Package/zabbix/Default)
  TITLE+= sender (with SSL)
  DEPENDS+= +ZABBIX_OPENSSL:libopenssl +ZABBIX_GNUTLS:libgnutls
  PROVIDES:=zabbix-sender
  VARIANT:=ssl
endef

define Package/zabbix-get-tiny
  $(call Package/zabbix/Default)
  TITLE+= get (minimum/nossl)
  PROVIDES:=zabbix-get
  VARIANT:=tiny
endef

define Package/zabbix-get-ssl
  $(call Package/zabbix/Default)
  TITLE+= get (with SSL)
  DEPENDS+= +ZABBIX_OPENSSL:libopenssl +ZABBIX_GNUTLS:libgnutls
  PROVIDES:=zabbix-get
  VARIANT:=ssl
endef

define Package/zabbix-server/Default
  $(call Package/zabbix/Default)
  DEPENDS += +ZABBIX_POSTGRESQL:libpq \
    +ZABBIX_MYSQL:libmariadbclient \
    +libevent2 \
    +libevent2-pthreads \
    +libevent2-extra \
    +fping
endef

define Package/zabbix-server-small
  $(call Package/zabbix-server/Default)
  TITLE+= server (minimum/nossl)
  PROVIDES:=zabbix-server
  VARIANT:=small
endef

define Package/zabbix-server-ssl
  $(call Package/zabbix-server/Default)
  TITLE+= server (with SSL)
  PROVIDES:=zabbix-server
  DEPENDS+= +ZABBIX_OPENSSL:libopenssl +ZABBIX_GNUTLS:libgnutls
  VARIANT:=ssl
endef

define Package/zabbix-server-full
  $(call Package/zabbix-server/Default)
  TITLE+= server (with SSL, SNMP, and cURL)
  PROVIDES:=zabbix-server
  DEPENDS += \
    +ZABBIX_OPENSSL:libopenssl \
    +ZABBIX_OPENSSL:libnetsnmp-ssl \
    +ZABBIX_OPENSSL:libcurl \
    +ZABBIX_GNUTLS:libgnutls \
    +ZABBIX_GNUTLS:libnetsnmp-nossl \
    +ZABBIX_GNUTLS:libcurl-gnutls \
    +libopenldap
  VARIANT:=full
endef

define Package/zabbix-server-frontend
  $(call Package/zabbix/Default)
  TITLE+= frontend
  DEPENDS += +php8 \
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
    +ZABBIX_POSTGRESQL:php8-mod-pgsql \
    +ZABBIX_MYSQL:php8-mod-mysqli
    VARIANT:=full
    PROVIDES:=frontend-server
endef

define Package/zabbix-server-frontend-extra-auth
  $(call Package/zabbix/Default)
  TITLE+= frontend (extra auth support)
  DEPENDS += +php8 \
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
    +ZABBIX_POSTGRESQL:php8-mod-pgsql \
    +ZABBIX_MYSQL:php8-mod-mysqli
    PROVIDES:=frontend-extra-auth
    VARIANT:=full
endef

define Package/zabbix-proxy/Default
  $(call Package/zabbix/Default)
  DEPENDS += \
    +libevent2 \
    +libevent2-pthreads \
    +libevent2-extra \
    +fping
endef

define Package/zabbix-proxy-tiny
  $(call Package/zabbix-proxy/Default)
  TITLE+= proxy (sqlite3/nossl)
  PROVIDES:= zabbix-proxy
  DEPENDS+= +libsqlite3
  VARIANT:=tiny
endef

define Package/zabbix-proxy-small
  $(call Package/zabbix-proxy/Default)
  TITLE+= proxy (nossl)
  DEPENDS += +ZABBIX_POSTGRESQL:libpq \
    +ZABBIX_MYSQL:libmariadbclient
  PROVIDES:= zabbix-proxy
  VARIANT:=small
endef

define Package/zabbix-proxy-ssl
  $(call Package/zabbix-proxy/Default)
  TITLE+= proxy (with SSL)
  PROVIDES:= zabbix-proxy
  DEPENDS += +ZABBIX_OPENSSL:libopenssl \
    +ZABBIX_GNUTLS:libgnutls \
    +ZABBIX_POSTGRESQL:libpq \
    +ZABBIX_MYSQL:libmariadbclient
  VARIANT:=ssl
endef

define Package/zabbix-proxy-full
  $(call Package/zabbix-proxy/Default)
  TITLE+= proxy (with SSL, SNMP, and cURL)
  PROVIDES:=zabbix-proxy
  DEPENDS += \
    +ZABBIX_OPENSSL:libopenssl \
    +ZABBIX_OPENSSL:libnetsnmp-ssl \
    +ZABBIX_OPENSSL:libcurl \
    +ZABBIX_GNUTLS:libgnutls \
    +ZABBIX_GNUTLS:libnetsnmp-nossl \
    +ZABBIX_GNUTLS:libcurl-gnutls \
    +libopenldap \
    +ZABBIX_POSTGRESQL:libpq \
    +ZABBIX_MYSQL:libmariadbclient
  VARIANT:=full
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

CONFIGURE_ARGS += \
	--enable-agent \
	$(call autoconf_bool,CONFIG_IPV6,ipv6) \
	--disable-java \
	--with-libevent=$(STAGING_DIR)/usr/include \
	--with-libpcre2=$(STAGING_DIR)/usr/include \
	--with-zlib=$(STAGING_DIR)/usr/include

ifneq ($(filter ssl full,$(BUILD_VARIANT)),)
ifeq ($(CONFIG_ZABBIX_OPENSSL),y)
CONFIGURE_ARGS+= --with-openssl="$(STAGING_DIR)/usr"
endif

ifeq ($(CONFIG_ZABBIX_GNUTLS),y)
CONFIGURE_ARGS+= --with-gnutls="$(STAGING_DIR)/usr"
endif
endif

ifeq ($(BUILD_VARIANT),tiny)
CONFIGURE_ARGS += --disable-server \
	--enable-proxy \
	$(if $(CONFIG_PACKAGE_zabbix-proxy-tiny),--with-sqlite3=$(STAGING_DIR)/usr)
endif

ifneq ($(filter small ssl full,$(BUILD_VARIANT)),)
CONFIGURE_ARGS += --enable-server \
	--enable-proxy \
	$(if $(CONFIG_ZABBIX_MYSQL),--with-mysql) \
	$(if $(CONFIG_ZABBIX_POSTGRESQL),--with-postgresql)
endif

ifeq ($(BUILD_VARIANT),full)
CONFIGURE_ARGS += --with-ldap="$(STAGING_DIR)/usr"
ifeq ($(CONFIG_ZABBIX_GNUTLS),y)
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
	LIBNETNSMP_CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
	LIBNETSNMP_LDFLAGS="-L$(STAGING_DIR)/usr/lib" \
	ac_cv_path__libnetsnmp_config_bin="/bin" \
	ac_cv_path__libnetsnmp_config_root="/bin/true"
CONFIGURE_ARGS += --with-net-snmp="yes"
else
CONFIGURE_ARGS += --with-libcurl
CONFIGURE_ARGS += \
	ac_cv_path__libnetsnmp_config_bin="$(STAGING_DIR)/host/bin" \
	ac_cv_path__libnetsnmp_config_root="$(STAGING_DIR)/host/bin/net-snmp-config"
CONFIGURE_ARGS += --with-net-snmp
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
Package/zabbix-agentd-ssl/conffiles = $(Package/zabbix-agentd/conffiles/Default)
Package/zabbix-agentd-full/conffiles = $(Package/zabbix-agentd/conffiles/Default)

define Package/zabbix-server/conffiles/Default
/etc/zabbix_server.conf
/etc/config/zabbix_server
/etc/sysctl.d/90-zabbix-discovery-workers.conf
endef
Package/zabbix-server-small/conffiles = $(Package/zabbix-server/conffiles/Default)
Package/zabbix-server-ssl/conffiles = $(Package/zabbix-server/conffiles/Default)
Package/zabbix-server-full/conffiles = $(Package/zabbix-server/conffiles/Default)

define Package/zabbix-proxy/conffiles/Default
/etc/zabbix_proxy.conf
endef
Package/zabbix-proxy-tiny/conffiles = $(Package/zabbix-proxy/conffiles/Default)
Package/zabbix-proxy-ssl/conffiles = $(Package/zabbix-proxy/conffiles/Default)
Package/zabbix-proxy-full/conffiles = $(Package/zabbix-proxy/conffiles/Default)

ifdef CONFIG_PACKAGE_zabbix-extra-mac80211
define Build/Prepare/zabbix-extra-mac80211
	mkdir -p $(PKG_BUILD_DIR)/zabbix-extra-mac80211
	$(CP) ./files/zabbix_helper_mac80211.c $(PKG_BUILD_DIR)/zabbix-extra-mac80211/
endef

define Build/Compile/zabbix-extra-mac80211
	$(TARGET_CC) $(TARGET_CFLAGS) $(PKG_BUILD_DIR)/zabbix-extra-mac80211/zabbix_helper_mac80211.c -o $(PKG_BUILD_DIR)/zabbix-extra-mac80211/zabbix_helper_mac80211
endef
endif

define Build/Prepare
	$(call Build/Prepare/Default)
	$(call Build/Prepare/zabbix-extra-mac80211)
endef

define Build/Compile
	$(call Build/Compile/Default)
	$(call Build/Compile/zabbix-extra-mac80211)
endef

define Package/zabbix-agentd/install/Default
	$(INSTALL_DIR) $(1)/etc/zabbix_agentd.conf.d
	$(call Package/zabbix/install/sbin,$(1),agentd)
	$(call Package/zabbix/install/etc,$(1),agentd)
	$(call Package/zabbix/install/init.d,$(1),agentd)
endef
Package/zabbix-agentd-tiny/install = $(Package/zabbix-agentd/install/Default)
Package/zabbix-agentd-ssl/install = $(Package/zabbix-agentd/install/Default)
Package/zabbix-agentd-full/install = $(Package/zabbix-agentd/install/Default)

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
Package/zabbix-sender-ssl/install = $(Package/zabbix-sender/install/Default)

define Package/zabbix-get/install/Default
	$(call Package/zabbix/install/bin,$(1),get)
endef
Package/zabbix-get-tiny/install = $(Package/zabbix-get/install/Default)
Package/zabbix-get-ssl/install = $(Package/zabbix-get/install/Default)

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
Package/zabbix-server-ssl/install = $(Package/zabbix-server/install/Default)
Package/zabbix-server-full/install = $(Package/zabbix-server/install/Default)

define Package/zabbix-server/postinst/Default
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || (. /etc/uci-defaults/90_zabbix_server) && rm -f /etc/uci-defaults/90_zabbix_server
exit 0
endef
Package/zabbix-server-small/postinst = $(Package/zabbix-server/postinst/Default)
Package/zabbix-server-ssl/postinst = $(Package/zabbix-server/postinst/Default)
Package/zabbix-server-full/postinst = $(Package/zabbix-server/postinst/Default)

define Package/zabbix-server-frontend/install/Default
	$(INSTALL_DIR) $(1)/www/zabbix
	$(CP) $(PKG_BUILD_DIR)/ui/* $(1)/www/zabbix
endef
Package/zabbix-server-frontend/install = $(Package/zabbix-server-frontend/install/Default)
Package/zabbix-server-frontend-extra-auth/install = $(Package/zabbix-server-frontend/install/Default)

define Package/zabbix-proxy/install/Default
	$(call Package/zabbix/install/sbin,$(1),proxy)
	$(call Package/zabbix/install/etc,$(1),proxy)
endef
Package/zabbix-proxy-tiny/install = $(Package/zabbix-proxy/install/Default)
Package/zabbix-proxy-small/install = $(Package/zabbix-proxy/install/Default)
Package/zabbix-proxy-ssl/install = $(Package/zabbix-proxy/install/Default)
Package/zabbix-proxy-full/install = $(Package/zabbix-proxy/install/Default)

$(eval $(call BuildPackage,zabbix-agentd-tiny))
$(eval $(call BuildPackage,zabbix-sender-tiny))
$(eval $(call BuildPackage,zabbix-get-tiny))
$(eval $(call BuildPackage,zabbix-proxy-tiny))
$(eval $(call BuildPackage,zabbix-proxy-small))
$(eval $(call BuildPackage,zabbix-server-small))
$(eval $(call BuildPackage,zabbix-agentd-ssl))
$(eval $(call BuildPackage,zabbix-sender-ssl))
$(eval $(call BuildPackage,zabbix-get-ssl))
$(eval $(call BuildPackage,zabbix-proxy-ssl))
$(eval $(call BuildPackage,zabbix-server-ssl))
$(eval $(call BuildPackage,zabbix-agentd-full))
$(eval $(call BuildPackage,zabbix-proxy-full))
$(eval $(call BuildPackage,zabbix-server-full))
$(eval $(call BuildPackage,zabbix-server-frontend))
$(eval $(call BuildPackage,zabbix-server-frontend-extra-auth))
$(eval $(call BuildPackage,zabbix-extra-mac80211))
$(eval $(call BuildPackage,zabbix-extra-network))
$(eval $(call BuildPackage,zabbix-extra-wifi))
