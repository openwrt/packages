#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zabbix
PKG_VERSION:=7.0.22
PKG_RELEASE:=5

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
  CONFIG_ZABBIX_SQLITE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/zabbix-proxy-nossl/config
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
endef

define Package/zabbix-agentd/Default
  $(call Package/zabbix/Default)
  TITLE+= agentd
  DEPENDS:= \
    $(ICONV_DEPENDS) \
    +libevent2-pthreads \
    +libpcre2 \
    +zlib
  PROVIDES:=zabbix-agentd
  USERID:=zabbix-agent=53:zabbix-agent=53
endef

define Package/zabbix-agentd-nossl
  $(call Package/zabbix-agentd/Default)
  TITLE+= (no SSL)
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-agentd-openssl
  $(call Package/zabbix-agentd/Default)
  TITLE+= (with OpenSSL)
  DEPENDS+= +libopenssl
  PROVIDES+= zabbix-agentd-ssl
  VARIANT:=openssl
endef

define Package/zabbix-agentd-gnutls
  $(call Package/zabbix-agentd/Default)
  TITLE+= (with GnuTLS)
  DEPENDS+= +libgnutls
  PROVIDES+= zabbix-agentd-ssl
  VARIANT:=gnutls
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

define Package/zabbix-sender-nossl
  $(call Package/zabbix-sender/Default)
  TITLE+= (no SSL)
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-sender-openssl
  $(call Package/zabbix-sender/Default)
  TITLE+= (with OpenSSL)
  DEPENDS+= +libopenssl
  PROVIDES+= zabbix-sender-ssl
  VARIANT:=openssl
endef

define Package/zabbix-sender-gnutls
  $(call Package/zabbix-sender/Default)
  TITLE+= (with GnuTLS)
  DEPENDS+= +libgnutls
  PROVIDES+= zabbix-sender-ssl
  VARIANT:=gnutls
endef

define Package/zabbix-get/Default
  $(call Package/zabbix/Default)
  TITLE+= get
  DEPENDS:= \
    $(ICONV_DEPENDS) \
    +libpcre2 \
    +zlib
  PROVIDES:=@zabbix-get
endef

define Package/zabbix-get-nossl
  $(call Package/zabbix-get/Default)
  TITLE+= (no SSL)
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-get-openssl
  $(call Package/zabbix-get/Default)
  TITLE+= (with OpenSSL)
  DEPENDS+= +libopenssl
  PROVIDES+= zabbix-get-ssl
  VARIANT:=openssl
endef

define Package/zabbix-get-gnutls
  $(call Package/zabbix-get/Default)
  TITLE+= (with GnuTLS)
  DEPENDS+= +libgnutls
  PROVIDES+= zabbix-get-ssl
  VARIANT:=gnutls
endef

define Package/zabbix-server-or-proxy/Default
  $(call Package/zabbix/Default)
  DEPENDS:= \
    $(ICONV_DEPENDS) \
    +ZABBIX_MYSQL:libmariadbclient \
    +ZABBIX_POSTGRESQL:libpq \
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
  DEPENDS+= @(!ZABBIX_SQLITE)
  PROVIDES:=zabbix-server
endef

define Package/zabbix-server-nossl
  $(call Package/zabbix-server/Default)
  TITLE+= (no SSL)
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-server-openssl
  $(call Package/zabbix-server/Default)
  TITLE+= (with OpenSSL)
  DEPENDS+= +libopenssl
  PROVIDES+= zabbix-server-ssl
  VARIANT:=openssl
endef

define Package/zabbix-server-gnutls
  $(call Package/zabbix-server/Default)
  TITLE+= (with GnuTLS)
  DEPENDS+= +libgnutls
  PROVIDES+= zabbix-server-ssl
  VARIANT:=gnutls
endef

define Package/zabbix-proxy/Default
  $(call Package/zabbix-server-or-proxy/Default)
  TITLE+= proxy
  DEPENDS+= +ZABBIX_SQLITE:libsqlite3
  PROVIDES:=zabbix-proxy
endef

define Package/zabbix-proxy-nossl
  $(call Package/zabbix-proxy/Default)
  TITLE+= (no SSL)
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
endef

define Package/zabbix-proxy-openssl
  $(call Package/zabbix-proxy/Default)
  TITLE+= (with OpenSSL)
  DEPENDS+= +libopenssl
  PROVIDES+= zabbix-proxy-ssl
  VARIANT:=openssl
endef

define Package/zabbix-proxy-gnutls
  $(call Package/zabbix-proxy/Default)
  TITLE+= (with GnuTLS)
  DEPENDS+= +libgnutls
  PROVIDES+= zabbix-proxy-ssl
  VARIANT:=gnutls
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

define Package/zabbix-frontend-server
  $(call Package/zabbix/Default)
  TITLE+= frontend server
  PKGARCH:=all
  DEPENDS:= \
    @PACKAGE_php8 \
    @ZABBIX_MYSQL:php8-mod-mysqli \
    @ZABBIX_POSTGRESQL:php8-mod-pgsql \
    @(!ZABBIX_SQLITE) \
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
  PROVIDES:=zabbix-server-frontend
  VARIANT:=no-configure
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

ifneq ($(BUILD_VARIANT),no-configure)

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

ifeq ($(BUILD_VARIANT),nossl)
	CONFIGURE_ARGS+= --with-openssl="no" --with-gnutls="no"
endif

ifeq ($(BUILD_VARIANT),openssl)
	CONFIGURE_ARGS+= --with-openssl="$(STAGING_DIR)/usr"
endif

ifeq ($(BUILD_VARIANT),gnutls)
	CONFIGURE_ARGS+= --with-gnutls="$(STAGING_DIR)/usr"
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

$(foreach zvariant,nossl openssl gnutls,$(eval $(call Package/zabbix-daemon/files,agentd,$(zvariant),,$(call Package/zabbix-agentd/install-extra))))
$(foreach zvariant,nossl openssl gnutls,$(eval $(call Package/zabbix-daemon/files,server,$(zvariant),$(call Package/zabbix-server/conffiles-extra),$(call Package/zabbix-server/install-extra))))
$(foreach zvariant,nossl openssl gnutls,$(eval $(call Package/zabbix-daemon/files,proxy,$(zvariant))))

# Due to nested defines, eval, and call, the extra spaces for the nested define
# is essential.
define Package/zabbix-server/postinst/Default
        define Package/zabbix-server-$(1)/postinst
  #!/bin/sh
  [ -n "$$$${IPKG_INSTROOT}" ] || (. /etc/uci-defaults/90_zabbix_server) && rm -f /etc/uci-defaults/90_zabbix_server
  exit 0
         endef
endef

$(foreach zvariant,nossl openssl gnutls,$(eval $(call Package/zabbix-server/postinst/Default,$(zvariant))))

define Package/zabbix-program/files
        define Package/zabbix-$(1)-$(2)/install
		$(call Package/zabbix/install/bin,$$(1),$(1))
        endef
endef

$(foreach zvariant,nossl openssl gnutls,$(eval $(call Package/zabbix-program/files,sender,$(zvariant))))
$(foreach zvariant,nossl openssl gnutls,$(eval $(call Package/zabbix-program/files,get,$(zvariant))))

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

define Package/zabbix-frontend-server/install
	$(INSTALL_DIR) $(1)/www/zabbix
	$(CP) $(PKG_BUILD_DIR)/ui/* $(1)/www/zabbix
endef

$(eval $(call BuildPackage,zabbix-agentd-nossl))
$(eval $(call BuildPackage,zabbix-agentd-openssl))
$(eval $(call BuildPackage,zabbix-agentd-gnutls))
$(eval $(call BuildPackage,zabbix-get-nossl))
$(eval $(call BuildPackage,zabbix-get-openssl))
$(eval $(call BuildPackage,zabbix-get-gnutls))
$(eval $(call BuildPackage,zabbix-sender-nossl))
$(eval $(call BuildPackage,zabbix-sender-openssl))
$(eval $(call BuildPackage,zabbix-sender-gnutls))
$(eval $(call BuildPackage,zabbix-proxy-nossl))
$(eval $(call BuildPackage,zabbix-proxy-openssl))
$(eval $(call BuildPackage,zabbix-proxy-gnutls))
$(eval $(call BuildPackage,zabbix-server-nossl))
$(eval $(call BuildPackage,zabbix-server-openssl))
$(eval $(call BuildPackage,zabbix-server-gnutls))
$(eval $(call BuildPackage,zabbix-extra-mac80211))
$(eval $(call BuildPackage,zabbix-extra-network))
$(eval $(call BuildPackage,zabbix-extra-wifi))
$(eval $(call BuildPackage,zabbix-frontend-server))
