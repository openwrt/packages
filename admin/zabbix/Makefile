#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zabbix
PKG_VERSION:=2.4.6
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/zabbix
PKG_MD5SUM:=06ad8d5808a0eddf2b9f0a256b6a5fde

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/zabbix/Default
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Zabbix
  URL:=http://www.zabbix.com/
  SUBMENU:=zabbix
  MAINTAINER:=Etienne CHAMPETIER <champetier.etienne@gmail.com>
  USERID:=zabbix=53:zabbix=53
endef

define Package/zabbix-agent
  $(call Package/zabbix/Default)
  TITLE+= agent
endef

define Package/zabbix-agentd
  $(call Package/zabbix/Default)
  TITLE+= agentd
endef

define Package/zabbix-extra-mac80211
  $(call Package/zabbix/Default)
  TITLE+= discovery/userparameters for mac80211
  DEPENDS += +zabbix-agentd @PACKAGE_MAC80211_DEBUGFS @KERNEL_DEBUG_FS
endef

define Package/zabbix-extra-network
  $(call Package/zabbix/Default)
  TITLE+= discovery/userparameters for network
  DEPENDS += +zabbix-agentd +libuci-lua +lua
endef

define Package/zabbix-extra-wifi
  $(call Package/zabbix/Default)
  TITLE+= discovery/userparameters for wifi
  DEPENDS += +zabbix-agentd +libiwinfo-lua +libuci-lua +lua
endef

define Package/zabbix-sender
  $(call Package/zabbix/Default)
  TITLE+= sender
endef

define Package/zabbix-get
  $(call Package/zabbix/Default)
  TITLE+= get
endef

define Package/zabbix-server
  $(call Package/zabbix/Default)
  TITLE+= server
  DEPENDS += +libsqlite3
endef

define Package/zabbix-proxy
  $(call Package/zabbix/Default)
  TITLE+= proxy
  DEPENDS += +libsqlite3
endef

define Package/zabbix-extra-mac80211/description
An extra package for zabbix-agentd that adds a discovery rule for mac80211 wifi phy and many userparameters.
It contains an suid helper to allow zabbix-agentd to still run as zabbix user and not as root.
See http://wiki.openwrt.org/doc/howto/zabbix for ready to use zabbix templates.
endef

define Package/zabbix-extra-network/description
An extra package for zabbix-agentd that adds a discovery rule for openwrt network interfaces.
The idea here is to discover only interfaces listed in /etc/config/network (discover br-lan and not eth0.1 and wlan0)
See http://wiki.openwrt.org/doc/howto/zabbix for ready to use zabbix templates.
endef

define Package/zabbix-extra-wifi/description
An extra package for zabbix-agentd that adds a discovery rule for wifi interfaces and many userparameters.
As it uses libiwinfo, it works with all wifi devices supported by openwrt.
See http://wiki.openwrt.org/doc/howto/zabbix for ready to use zabbix templates.
endef

CONFIGURE_ARGS+= \
	--enable-agent \
	--enable-server \
	--enable-proxy \
	$(call autoconf_bool,CONFIG_IPV6,ipv6) \
	--disable-java \
	--with-sqlite3="$(STAGING_DIR)/usr"

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

define Package/zabbix-agent/conffiles
/etc/zabbix_agent.conf
endef
define Package/zabbix-agentd/conffiles
/etc/zabbix_agentd.conf
endef
define Package/zabbix-server/conffiles
/etc/zabbix_server.conf
endef
define Package/zabbix-proxy/conffiles
/etc/zabbix_proxy.conf
endef

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

define Package/zabbix-agent/install
	$(call Package/zabbix/install/sbin,$(1),agent)
	$(call Package/zabbix/install/etc,$(1),agent)
endef

define Package/zabbix-agentd/install
	$(INSTALL_DIR) $(1)/etc/zabbix_agentd.conf.d
	$(call Package/zabbix/install/sbin,$(1),agentd)
	$(call Package/zabbix/install/etc,$(1),agentd)
	$(call Package/zabbix/install/init.d,$(1),agentd)
endef

define Package/zabbix-extra-mac80211/install
	$(call Package/zabbix/install/zabbix.conf.d,$(1),mac80211)
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/zabbix-extra-mac80211/zabbix_helper_mac80211 $(1)/usr/bin/
	chmod 4755 $(1)/usr/bin/zabbix_helper_mac80211
endef

define Package/zabbix-extra-network/install
	$(call Package/zabbix/install/zabbix.conf.d,$(1),network)
endef

define Package/zabbix-extra-wifi/install
	$(call Package/zabbix/install/zabbix.conf.d,$(1),wifi)
endef

define Package/zabbix-sender/install
	$(call Package/zabbix/install/bin,$(1),sender)
endef

define Package/zabbix-get/install
	$(call Package/zabbix/install/bin,$(1),get)
endef

define Package/zabbix-server/install
	$(call Package/zabbix/install/sbin,$(1),server)
	$(call Package/zabbix/install/etc,$(1),server)
endef

define Package/zabbix-proxy/install
	$(call Package/zabbix/install/sbin,$(1),proxy)
	$(call Package/zabbix/install/etc,$(1),proxy)
endef

$(eval $(call BuildPackage,zabbix-agent))
$(eval $(call BuildPackage,zabbix-agentd))
$(eval $(call BuildPackage,zabbix-extra-mac80211))
$(eval $(call BuildPackage,zabbix-extra-network))
$(eval $(call BuildPackage,zabbix-extra-wifi))
$(eval $(call BuildPackage,zabbix-sender))
$(eval $(call BuildPackage,zabbix-server))
$(eval $(call BuildPackage,zabbix-proxy))
$(eval $(call BuildPackage,zabbix-get))
