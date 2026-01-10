#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zabbix
PKG_VERSION:=7.0.21
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://cdn.zabbix.com/zabbix/sources/stable/$(basename $(PKG_VERSION))/ \
	https://cdn.zabbix.com/zabbix/sources/oldstable/$(basename $(PKG_VERSION))/
PKG_HASH:=a7f82c1610bc02e4ac42f5257c0265f92e32b51fb5e04b4ad29f72e97189d3ef

PKG_MAINTAINER:=Daniel F. Dickinson <dfdpublic@wildtechgarden.ca>
PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:zabbix:zabbix

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_CONFIG_DEPENDS:= \
  CONFIG_ZABBIX_MYSQL \
  CONFIG_ZABBIX_POSTGRESQL \
  CONFIG_ZABBIX_SQLITE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/zabbix-proxy/config
comment "Database Software"

choice
        prompt "Selected Database Software"
        default ZABBIX_POSTGRESQL

        config ZABBIX_MYSQL
                bool "MySQL/MariaDB"

        config ZABBIX_POSTGRESQL
                bool "PostgreSQL"

        config ZABBIX_SQLITE
                bool "SQLite"
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

define Package/zabbix-agentd
  $(call Package/zabbix/Default)
  TITLE+= agentd
  DEPENDS+= +libevent2-pthreads
  PROVIDES:=zabbix-agentd
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-agentd-openssl
  $(call Package/zabbix/Default)
  TITLE+= agentd (with OpenSSL)
  DEPENDS+= +libevent2-pthreads +libopenssl
  PROVIDES:=zabbix-agentd
  VARIANT:=openssl
endef

define Package/zabbix-agentd-gnutls
  $(call Package/zabbix/Default)
  TITLE+= agentd (with GnuTLS)
  DEPENDS+= +libevent2-pthreads +libgnutls
  PROVIDES:=zabbix-agentd
  VARIANT:=gnutls
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

define Package/zabbix-sender
  $(call Package/zabbix/Default)
  TITLE+= sender
  PROVIDES:=zabbix-sender
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-sender-openssl
  $(call Package/zabbix/Default)
  TITLE+= sender (with OpenSSL)
  DEPENDS+= +libopenssl
  PROVIDES:=zabbix-sender
  VARIANT:=openssl
endef

define Package/zabbix-sender-gnutls
  $(call Package/zabbix/Default)
  TITLE+= sender (with GnuTLS)
  DEPENDS+= +libgnutls
  PROVIDES:=zabbix-sender
  VARIANT:=gnutls
endef

define Package/zabbix-get
  $(call Package/zabbix/Default)
  TITLE+= get
  PROVIDES:=zabbix-get
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-get-openssl
  $(call Package/zabbix/Default)
  TITLE+= get (with OpenSSL)
  DEPENDS+= +libopenssl
  PROVIDES:=zabbix-get
  VARIANT:=openssl
endef

define Package/zabbix-get-gnutls
  $(call Package/zabbix/Default)
  TITLE+= get (with GnuTLS)
  DEPENDS+= +libgnutls
  PROVIDES:=zabbix-get
  VARIANT:=gnutls
endef

define Package/zabbix-server/Default
  $(call Package/zabbix/Default)
  TITLE+= server
  DEPENDS += +ZABBIX_POSTGRESQL:libpq \
    +ZABBIX_MYSQL:libmariadbclient \
    @(!ZABBIX_SQLITE) \
    +libevent2 \
    +libevent2-pthreads \
    +libevent2-extra \
    +fping
endef

define Package/zabbix-server
  $(call Package/zabbix-server/Default)
  PROVIDES:=zabbix-server
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-server-openssl
  $(call Package/zabbix-server/Default)
  TITLE+= (with OpenSSL)
  PROVIDES:=zabbix-server
  DEPENDS+= +libopenssl
  VARIANT:=openssl
endef

define Package/zabbix-server-gnutls
  $(call Package/zabbix-server/Default)
  TITLE+= (with GnuTLS)
  PROVIDES:=zabbix-server
  DEPENDS+= +libgnutls
  VARIANT:=gnutls
endef

define Package/zabbix-server-frontend
  $(call Package/zabbix/Default)
  TITLE+= server-frontend
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
    +ZABBIX_POSTGRESQL:php8-mod-pgsql \
    +ZABBIX_MYSQL:php8-mod-mysqli \
    @(!ZABBIX_SQLITE)
endef

define Package/zabbix-proxy/Default
  $(call Package/zabbix/Default)
  TITLE+= proxy
  DEPENDS += +ZABBIX_POSTGRESQL:libpq \
    +ZABBIX_MYSQL:libmariadbclient \
    +ZABBIX_SQLITE:libsqlite3 \
    +libevent2 \
    +libevent2-pthreads \
    +libevent2-extra \
    +fping
endef

define Package/zabbix-proxy
  $(call Package/zabbix-proxy/Default)
  PROVIDES:=zabbix-proxy
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-proxy-openssl
  $(call Package/zabbix-proxy/Default)
  TITLE+= (with OpenSSL)
  PROVIDES:=zabbix-proxy
  DEPENDS+= +libopenssl
  VARIANT:=openssl
endef

define Package/zabbix-proxy-gnutls
  $(call Package/zabbix-proxy/Default)
  TITLE+= (with GnuTLS)
  PROVIDES:=zabbix-proxy
  DEPENDS+= +libgnutls
  VARIANT:=gnutls
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

CONFIGURE_ARGS+= \
	--enable-agent \
	$(if $(CONFIG_ZABBIX_SQLITE),--disable-server,--enable-server) \
	--enable-proxy \
	$(call autoconf_bool,CONFIG_IPV6,ipv6) \
	--disable-java \
	$(if $(CONFIG_ZABBIX_MYSQL),--with-mysql) \
	$(if $(CONFIG_ZABBIX_POSTGRESQL),--with-postgresql) \
	$(if $(CONFIG_ZABBIX_SQLITE),--with-sqlite3=$(STAGING_DIR)/usr) \
	--with-libevent=$(STAGING_DIR)/usr/include \
	--with-libpcre2=$(STAGING_DIR)/usr/include \
	--with-zlib=$(STAGING_DIR)/usr/include

ifeq ($(BUILD_VARIANT),openssl)
	CONFIGURE_ARGS+= --with-openssl="$(STAGING_DIR)/usr"
endif

ifeq ($(BUILD_VARIANT),gnutls)
	CONFIGURE_ARGS+= --with-gnutls="$(STAGING_DIR)/usr"
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

define Package/zabbix-agentd/conffiles
/etc/zabbix_agentd.conf
endef
Package/zabbix-agentd-openssl/conffiles = $(Package/zabbix-agentd/conffiles)
Package/zabbix-agentd-gnutls/conffiles = $(Package/zabbix-agentd/conffiles)

define Package/zabbix-server/conffiles
/etc/zabbix_server.conf
endef
Package/zabbix-server-openssl/conffiles = $(Package/zabbix-server/conffiles)
Package/zabbix-server-gnutls/conffiles = $(Package/zabbix-server/conffiles)

define Package/zabbix-proxy/conffiles
/etc/zabbix_proxy.conf
endef
Package/zabbix-proxy-openssl/conffiles = $(Package/zabbix-proxy/conffiles)
Package/zabbix-proxy-gnutls/conffiles = $(Package/zabbix-proxy/conffiles)

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

define Package/zabbix-agentd/install
	$(INSTALL_DIR) $(1)/etc/zabbix_agentd.conf.d
	$(call Package/zabbix/install/sbin,$(1),agentd)
	$(call Package/zabbix/install/etc,$(1),agentd)
	$(call Package/zabbix/install/init.d,$(1),agentd)
endef
Package/zabbix-agentd-openssl/install = $(Package/zabbix-agentd/install)
Package/zabbix-agentd-gnutls/install = $(Package/zabbix-agentd/install)

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

define Package/zabbix-sender/install
	$(call Package/zabbix/install/bin,$(1),sender)
endef
Package/zabbix-sender-openssl/install = $(Package/zabbix-sender/install)
Package/zabbix-sender-gnutls/install = $(Package/zabbix-sender/install)

define Package/zabbix-get/install
	$(call Package/zabbix/install/bin,$(1),get)
endef
Package/zabbix-get-openssl/install = $(Package/zabbix-get/install)
Package/zabbix-get-gnutls/install = $(Package/zabbix-get/install)

define Package/zabbix-server/install
	$(call Package/zabbix/install/sbin,$(1),server)
	$(call Package/zabbix/install/etc,$(1),server)
endef
Package/zabbix-server-openssl/install = $(Package/zabbix-server/install)
Package/zabbix-server-gnutls/install = $(Package/zabbix-server/install)

define Package/zabbix-server-frontend/install
	$(INSTALL_DIR) $(1)/www/zabbix
	$(CP) $(PKG_BUILD_DIR)/ui/* $(1)/www/zabbix
endef

define Package/zabbix-proxy/install
	$(call Package/zabbix/install/sbin,$(1),proxy)
	$(call Package/zabbix/install/etc,$(1),proxy)
endef
Package/zabbix-proxy-openssl/install = $(Package/zabbix-proxy/install)
Package/zabbix-proxy-gnutls/install = $(Package/zabbix-proxy/install)

$(eval $(call BuildPackage,zabbix-agentd))
$(eval $(call BuildPackage,zabbix-agentd-openssl))
$(eval $(call BuildPackage,zabbix-agentd-gnutls))
$(eval $(call BuildPackage,zabbix-extra-mac80211))
$(eval $(call BuildPackage,zabbix-extra-network))
$(eval $(call BuildPackage,zabbix-extra-wifi))
$(eval $(call BuildPackage,zabbix-sender))
$(eval $(call BuildPackage,zabbix-sender-openssl))
$(eval $(call BuildPackage,zabbix-sender-gnutls))
$(eval $(call BuildPackage,zabbix-server))
$(eval $(call BuildPackage,zabbix-server-openssl))
$(eval $(call BuildPackage,zabbix-server-gnutls))
$(eval $(call BuildPackage,zabbix-server-frontend))
$(eval $(call BuildPackage,zabbix-proxy))
$(eval $(call BuildPackage,zabbix-proxy-openssl))
$(eval $(call BuildPackage,zabbix-proxy-gnutls))
$(eval $(call BuildPackage,zabbix-get))
$(eval $(call BuildPackage,zabbix-get-openssl))
$(eval $(call BuildPackage,zabbix-get-gnutls))
