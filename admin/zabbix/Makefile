#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zabbix
PKG_VERSION:=5.0.18
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://cdn.zabbix.com/zabbix/sources/stable/5.0/
PKG_HASH:=7d15c4d683801edc2bdcda3fd94afdf6a7142a1a92aa71f4a9220af8e39d9e0e

PKG_MAINTAINER:=Etienne CHAMPETIER <champetier.etienne@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:zabbix:zabbix

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_CONFIG_DEPENDS:= \
  CONFIG_ZABBIX_MYSQL \
  CONFIG_ZABBIX_POSTGRESQL

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/zabbix-server/config
comment "Database Software"

choice
        prompt "Selected Database Software"
        default ZABBIX_POSTGRESQL

        config ZABBIX_MYSQL
                bool "MySQL/MariaDB"

        config ZABBIX_POSTGRESQL
                bool "PostgreSQL"

endchoice
endef

define Package/zabbix/Default
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=Zabbix
  TITLE:=Zabbix
  URL:=https://www.zabbix.com/
  USERID:=zabbix=53:zabbix=53
  DEPENDS += $(ICONV_DEPENDS) +libpcre +zlib
endef

define Package/zabbix-agentd
  $(call Package/zabbix/Default)
  TITLE+= agentd
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-agentd-openssl
  $(call Package/zabbix/Default)
  TITLE+= agentd (with OpenSSL)
  DEPENDS+= +libopenssl
  VARIANT:=openssl
endef

define Package/zabbix-agentd-gnutls
  $(call Package/zabbix/Default)
  TITLE+= agentd (with GnuTLS)
  DEPENDS+= +libgnutls
  VARIANT:=gnutls
endef

define Package/zabbix-extra-mac80211/Default
  $(call Package/zabbix/Default)
  TITLE+= discovery/userparameters for mac80211
  DEPENDS = @PACKAGE_MAC80211_DEBUGFS @KERNEL_DEBUG_FS
endef

define Package/zabbix-extra-mac80211
  $(call Package/zabbix-extra-mac80211/Default)
  DEPENDS+= +zabbix-agentd
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-extra-mac80211-openssl
  $(call Package/zabbix-extra-mac80211/Default)
  TITLE+= (with OpenSSL)
  DEPENDS+= +zabbix-agentd-openssl
  VARIANT:=openssl
endef

define Package/zabbix-extra-mac80211-gnutls
  $(call Package/zabbix-extra-mac80211/Default)
  TITLE+= (with GnuTLS)
  DEPENDS+= +zabbix-agentd-gnutls
  VARIANT:=gnutls
endef

define Package/zabbix-extra-network/Default
  $(call Package/zabbix/Default)
  TITLE+= discovery/userparameters for network
  DEPENDS = +libubus-lua +lua
endef

define Package/zabbix-extra-network
  $(call Package/zabbix-extra-network/Default)
  DEPENDS+= +zabbix-agentd
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-extra-network-openssl
  $(call Package/zabbix-extra-network/Default)
  TITLE+= (with OpenSSL)
  DEPENDS+= +zabbix-agentd-openssl
  VARIANT:=openssl
endef

define Package/zabbix-extra-network-gnutls
  $(call Package/zabbix-extra-network/Default)
  TITLE+= (with GnuTLS)
  DEPENDS+= +zabbix-agentd-gnutls
  VARIANT:=gnutls
endef

define Package/zabbix-extra-wifi/Default
  $(call Package/zabbix/Default)
  TITLE+= discovery/userparameters for wifi
  DEPENDS = +libiwinfo-lua +libubus-lua +lua
endef

define Package/zabbix-extra-wifi
  $(call Package/zabbix-extra-wifi/Default)
  DEPENDS+= +zabbix-agentd
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-extra-wifi-openssl
  $(call Package/zabbix-extra-wifi/Default)
  TITLE+= (with OpenSSL)
  DEPENDS+= +zabbix-agentd-openssl
  VARIANT:=openssl
endef

define Package/zabbix-extra-wifi-gnutls
  $(call Package/zabbix-extra-wifi/Default)
  TITLE+= (with GnuTLS)
  DEPENDS+= +zabbix-agentd-gnutls
  VARIANT:=gnutls
endef

define Package/zabbix-sender
  $(call Package/zabbix/Default)
  TITLE+= sender
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-sender-openssl
  $(call Package/zabbix/Default)
  TITLE+= sender (with OpenSSL)
  DEPENDS+= +libopenssl
  VARIANT:=openssl
endef

define Package/zabbix-sender-gnutls
  $(call Package/zabbix/Default)
  TITLE+= sender (with GnuTLS)
  DEPENDS+= +libgnutls
  VARIANT:=gnutls
endef

define Package/zabbix-get
  $(call Package/zabbix/Default)
  TITLE+= get
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-get-openssl
  $(call Package/zabbix/Default)
  TITLE+= get (with OpenSSL)
  DEPENDS+= +libopenssl
  VARIANT:=openssl
endef

define Package/zabbix-get-gnutls
  $(call Package/zabbix/Default)
  TITLE+= get (with GnuTLS)
  DEPENDS+= +libgnutls
  VARIANT:=gnutls
endef

define Package/zabbix-server/Default
  $(call Package/zabbix/Default)
  TITLE+= server
  DEPENDS += +ZABBIX_POSTGRESQL:libpq +ZABBIX_MYSQL:libmariadbclient +libevent2
endef

define Package/zabbix-server
  $(call Package/zabbix-server/Default)
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-server-openssl
  $(call Package/zabbix-server/Default)
  TITLE+= (with OpenSSL)
  DEPENDS += +libopenssl
  VARIANT:=openssl
endef

define Package/zabbix-server-gnutls
  $(call Package/zabbix-server/Default)
  TITLE+= (with GnuTLS)
  DEPENDS+= +libgnutls
  VARIANT:=gnutls
endef

define Package/zabbix-server-frontend/Default
  $(call Package/zabbix/Default)
  TITLE+= server-frontend
  DEPENDS += +php8 +php8-cgi +ZABBIX_POSTGRESQL:php8-mod-pgsql +ZABBIX_MYSQL:php8-mod-mysqli \
  +php8-mod-gd +php8-mod-bcmath +php8-mod-ctype +php8-mod-xmlreader +php8-mod-xmlwriter \
  +php8-mod-session +php8-mod-sockets +php8-mod-mbstring +php8-mod-gettext
endef

define Package/zabbix-server-frontend
  $(call Package/zabbix-server-frontend/Default)
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-server-frontend-openssl
  $(call Package/zabbix-server-frontend/Default)
  TITLE+= (with OpenSSL)
  DEPENDS += +libopenssl
  VARIANT:=openssl
endef

define Package/zabbix-server-frontend-gnutls
  $(call Package/zabbix-server-frontend/Default)
  TITLE+= (with GnuTLS)
  DEPENDS += +libgnutls
  VARIANT:=gnutls
endef

define Package/zabbix-proxy/Default
  $(call Package/zabbix/Default)
  TITLE+= proxy
  DEPENDS += +ZABBIX_POSTGRESQL:libpq +ZABBIX_MYSQL:libmariadbclient +libevent2
endef

define Package/zabbix-proxy
  $(call Package/zabbix-proxy/Default)
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-proxy-openssl
  $(call Package/zabbix-proxy/Default)
  TITLE+= (with OpenSSL)
  DEPENDS+= +libopenssl
  VARIANT:=openssl
endef

define Package/zabbix-proxy-gnutls
  $(call Package/zabbix-proxy/Default)
  TITLE+= (with GnuTLS)
  DEPENDS+= +libgnutls
  VARIANT:=gnutls
endef

define Package/zabbix-extra-mac80211/description
An extra package for zabbix-agentd that adds a discovery rule for mac80211 wifi phy and many userparameters.
It contains an suid helper to allow zabbix-agentd to still run as zabbix user and not as root.
See https://openwrt.org/docs/guide-user/services/network_monitoring/zabbix for ready to use zabbix templates.
endef
Package/zabbix-extra-mac80211-openssl/description = $(Package/zabbix-extra-mac80211/description)
Package/zabbix-extra-mac80211-gnutls/description = $(Package/zabbix-extra-mac80211/description)

define Package/zabbix-extra-network/description
An extra package for zabbix-agentd that adds a discovery rule for openwrt network interfaces.
The idea here is to discover only interfaces listed in /etc/config/network (discover br-lan and not eth0.1 and wlan0)
See https://openwrt.org/docs/guide-user/services/network_monitoring/zabbix for ready to use zabbix templates.
endef
Package/zabbix-extra-network-openssl/description = $(Package/zabbix-extra-network/description)
Package/zabbix-extra-network-gnutls/description = $(Package/zabbix-extra-network/description)

define Package/zabbix-extra-wifi/description
An extra package for zabbix-agentd that adds a discovery rule for wifi interfaces and many userparameters.
As it uses libiwinfo, it works with all wifi devices supported by openwrt.
See https://openwrt.org/docs/guide-user/services/network_monitoring/zabbix for ready to use zabbix templates.
endef
Package/zabbix-extra-wifi-openssl/description = $(Package/zabbix-extra-wifi/description)
Package/zabbix-extra-wifi-gnutls/description = $(Package/zabbix-extra-wifi/description)

CONFIGURE_ARGS+= \
	--enable-agent \
	--enable-server \
	--enable-proxy \
	$(call autoconf_bool,CONFIG_IPV6,ipv6) \
	--disable-java \
	$(if $(CONFIG_ZABBIX_MYSQL),--with-mysql) \
	$(if $(CONFIG_ZABBIX_POSTGRESQL),--with-postgresql) \
	--with-libevent=$(STAGING_DIR)/usr/include/libevent \
	--with-libpcre=$(STAGING_DIR)/usr/include \
	--with-zlib=$(STAGING_DIR)/usr/include

ifeq ($(BUILD_VARIANT),openssl)
  CONFIGURE_ARGS+= --with-openssl="$(STAGING_DIR)/usr"
endif
ifeq ($(BUILD_VARIANT),gnutls)
  CONFIGURE_ARGS+= --with-gnutls="$(STAGING_DIR)/usr"
endif

CONFIGURE_VARS += \
	ac_cv_header_sys_sysinfo_h=no

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

define Build/Prepare/zabbix-extra-mac80211/Template
	mkdir -p $(PKG_BUILD_DIR)/zabbix-extra-mac80211
	$(CP) ./files/zabbix_helper_mac80211.c $(PKG_BUILD_DIR)/zabbix-extra-mac80211/
endef

define Build/Compile/zabbix-extra-mac80211/Template
	$(TARGET_CC) $(TARGET_CFLAGS) $(PKG_BUILD_DIR)/zabbix-extra-mac80211/zabbix_helper_mac80211.c -o $(PKG_BUILD_DIR)/zabbix-extra-mac80211/zabbix_helper_mac80211
endef

ifdef CONFIG_PACKAGE_zabbix-extra-mac80211
Build/Prepare/zabbix-extra-mac80211 = $(Build/Prepare/zabbix-extra-mac80211/Template)
Build/Compile/zabbix-extra-mac80211 = $(Build/Compile/zabbix-extra-mac80211/Template)
endif

ifdef CONFIG_PACKAGE_zabbix-extra-mac80211-openssl
Build/Prepare/zabbix-extra-mac80211-openssl = $(Build/Prepare/zabbix-extra-mac80211/Template)
Build/Compile/zabbix-extra-mac80211-openssl = $(Build/Compile/zabbix-extra-mac80211/Template)
endif

ifdef CONFIG_PACKAGE_zabbix-extra-mac80211-gnutls
Build/Prepare/zabbix-extra-mac80211-gnutls = $(Build/Prepare/zabbix-extra-mac80211/Template)
Build/Compile/zabbix-extra-mac80211-gnutls = $(Build/Compile/zabbix-extra-mac80211/Template)
endif

define Build/Prepare
	$(call Build/Prepare/Default)
ifeq ($(BUILD_VARIANT),nossl)
	$(call Build/Prepare/zabbix-extra-mac80211)
endif
ifeq ($(BUILD_VARIANT),openssl)
	$(call Build/Prepare/zabbix-extra-mac80211-openssl)
endif
ifeq ($(BUILD_VARIANT),gnutls)
	$(call Build/Prepare/zabbix-extra-mac80211-gnutls)
endif
endef

define Build/Compile
	$(call Build/Compile/Default)
ifeq ($(BUILD_VARIANT),nossl)
	$(call Build/Compile/zabbix-extra-mac80211)
endif
ifeq ($(BUILD_VARIANT),openssl)
	$(call Build/Compile/zabbix-extra-mac80211-openssl)
endif
ifeq ($(BUILD_VARIANT),gnutls)
	$(call Build/Compile/zabbix-extra-mac80211-gnutls)
endif
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
Package/zabbix-extra-mac80211-openssl/install = $(Package/zabbix-extra-mac80211/install)
Package/zabbix-extra-mac80211-gnutls/install = $(Package/zabbix-extra-mac80211/install)

define Package/zabbix-extra-network/install
	$(call Package/zabbix/install/zabbix.conf.d,$(1),network)
	$(INSTALL_DIR) $(1)/usr/share/acl.d
	$(INSTALL_DATA) ./files/zabbix-network-ubus-acl.json $(1)/usr/share/acl.d/zabbix-network.json
endef
Package/zabbix-extra-network-openssl/install = $(Package/zabbix-extra-network/install)
Package/zabbix-extra-network-gnutls/install = $(Package/zabbix-extra-network/install)

define Package/zabbix-extra-network/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	killall -s HUP ubusd
fi
endef
Package/zabbix-extra-network-openssl/postinst = $(Package/zabbix-extra-network/postinst)
Package/zabbix-extra-network-gnutls/postinst = $(Package/zabbix-extra-network/postinst)

define Package/zabbix-extra-wifi/install
	$(call Package/zabbix/install/zabbix.conf.d,$(1),wifi)
	$(INSTALL_DIR) $(1)/usr/share/acl.d
	$(INSTALL_DATA) ./files/zabbix-wifi-ubus-acl.json $(1)/usr/share/acl.d/zabbix-wifi.json
endef
Package/zabbix-extra-wifi-openssl/install = $(Package/zabbix-extra-wifi/install)
Package/zabbix-extra-wifi-gnutls/install = $(Package/zabbix-extra-wifi/install)

define Package/zabbix-extra-wifi/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	killall -s HUP ubusd
fi
endef
Package/zabbix-extra-wifi-openssl/postinst = $(Package/zabbix-extra-wifi/postinst)
Package/zabbix-extra-wifi-gnutls/postinst = $(Package/zabbix-extra-wifi/postinst)

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
Package/zabbix-server-frontend-openssl/install = $(Package/zabbix-server-frontend/install)
Package/zabbix-server-frontend-gnutls/install = $(Package/zabbix-server-frontend/install)

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
$(eval $(call BuildPackage,zabbix-extra-mac80211-openssl))
$(eval $(call BuildPackage,zabbix-extra-mac80211-gnutls))
$(eval $(call BuildPackage,zabbix-extra-network))
$(eval $(call BuildPackage,zabbix-extra-network-openssl))
$(eval $(call BuildPackage,zabbix-extra-network-gnutls))
$(eval $(call BuildPackage,zabbix-extra-wifi))
$(eval $(call BuildPackage,zabbix-extra-wifi-openssl))
$(eval $(call BuildPackage,zabbix-extra-wifi-gnutls))
$(eval $(call BuildPackage,zabbix-sender))
$(eval $(call BuildPackage,zabbix-sender-openssl))
$(eval $(call BuildPackage,zabbix-sender-gnutls))
$(eval $(call BuildPackage,zabbix-server))
$(eval $(call BuildPackage,zabbix-server-openssl))
$(eval $(call BuildPackage,zabbix-server-gnutls))
$(eval $(call BuildPackage,zabbix-server-frontend))
$(eval $(call BuildPackage,zabbix-server-frontend-openssl))
$(eval $(call BuildPackage,zabbix-server-frontend-gnutls))
$(eval $(call BuildPackage,zabbix-proxy))
$(eval $(call BuildPackage,zabbix-proxy-openssl))
$(eval $(call BuildPackage,zabbix-proxy-gnutls))
$(eval $(call BuildPackage,zabbix-get))
$(eval $(call BuildPackage,zabbix-get-openssl))
$(eval $(call BuildPackage,zabbix-get-gnutls))
