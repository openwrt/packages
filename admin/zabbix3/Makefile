#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zabbix3
<<<<<<< HEAD
PKG_VERSION:=3.0.1
PKG_RELEASE:=1

PKG_SOURCE:=zabbix-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/zabbix
PKG_MD5SUM:=890d9eec69304ad552959fabe0a5d122
=======
PKG_VERSION:=3.0.0beta1
PKG_RELEASE:=2

PKG_SOURCE:=zabbix-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/zabbix
PKG_MD5SUM:=979370195fbb967c0e80889f62c25fc7
>>>>>>> e44986d9a6454e5f58bff640a0185eb6a2ca5e26
PKG_BUILD_DIR:=$(BUILD_DIR)/zabbix3-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/zabbix3/Default
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Zabbix
  URL:=http://www.zabbix.com/
  SUBMENU:=zabbix3
  MAINTAINER:=Etienne CHAMPETIER <champetier.etienne@gmail.com>
endef

define Package/zabbix3-agentd
  $(call Package/zabbix3/Default)
  TITLE+= agentd
<<<<<<< HEAD
  DEPENDS+= +libopenssl
=======
  DEPENDS+= +libopenssl +libiconv-full
>>>>>>> e44986d9a6454e5f58bff640a0185eb6a2ca5e26
endef

define Package/zabbix3-extra-owrt
  $(call Package/zabbix3/Default)
  TITLE+= discovery/userparameters for OpenWrt
  DEPENDS += +zabbix3-agentd
endef

define Package/zabbix3-extra-mac80211
  $(call Package/zabbix3/Default)
  TITLE+= discovery/userparameters for mac80211
  DEPENDS += +zabbix3-agentd @PACKAGE_MAC80211_DEBUGFS @KERNEL_DEBUG_FS
endef

define Package/zabbix3-extra-network
  $(call Package/zabbix3/Default)
  TITLE+= discovery/userparameters for network
  DEPENDS += +zabbix3-agentd +libuci-lua +lua
endef

define Package/zabbix3-extra-wifi
  $(call Package/zabbix3/Default)
  TITLE+= discovery/userparameters for wifi
  DEPENDS += +zabbix3-agentd +libiwinfo-lua +libuci-lua +lua +libubus-lua
endef

define Package/zabbix3-sender
  $(call Package/zabbix3/Default)
  TITLE+= sender
  DEPENDS += +libopenssl
endef

define Package/zabbix3-get
  $(call Package/zabbix3/Default)
  TITLE+= get
  DEPENDS += +libopenssl
endef

define Package/zabbix3-server
  $(call Package/zabbix3/Default)
  TITLE+= server
  DEPENDS += +libsqlite3 +libopenssl
endef

define Package/zabbix3-proxy
  $(call Package/zabbix3/Default)
  TITLE+= proxy
  DEPENDS += +libsqlite3 +libopenssl
endef

define Package/zabbix3-extra-owrt/description
An extra package for zabbix-agentd that monitors OpenWrt specific things
See http://wiki.openwrt.org/doc/howto/zabbix for ready to use zabbix templates.
endef

define Package/zabbix3-extra-mac80211/description
An extra package for zabbix-agentd that adds a discovery rule for mac80211 wifi phy and many userparameters.
It contains an suid helper to allow zabbix-agentd to still run as zabbix user and not as root.
See http://wiki.openwrt.org/doc/howto/zabbix for ready to use zabbix templates.
endef

define Package/zabbix3-extra-network/description
An extra package for zabbix-agentd that adds a discovery rule for openwrt network interfaces.
The idea here is to discover only interfaces listed in /etc/config/network (discover br-lan and not eth0.1 and wlan0)
See http://wiki.openwrt.org/doc/howto/zabbix for ready to use zabbix templates.
endef

define Package/zabbix3-extra-wifi/description
An extra package for zabbix-agentd that adds a discovery rule for wifi interfaces and many userparameters.
As it uses libiwinfo, it works with all wifi devices supported by openwrt.
See http://wiki.openwrt.org/doc/howto/zabbix for ready to use zabbix templates.
endef

CONFIGURE_ARGS+= \
	--enable-agent \
	--enable-server \
	--enable-proxy \
	--disable-java \
	--with-openssl="$(STAGING_DIR)/usr" \
	--with-sqlite3="$(STAGING_DIR)/usr"

MAKE_FLAGS += ARCH="linux"

define Package/zabbix3/install/sbin
	$(INSTALL_DIR) \
		$(1)/usr/sbin

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/sbin/zabbix_$(2) \
		$(1)/usr/sbin/
endef

define Package/zabbix3/install/bin
	$(INSTALL_DIR) \
		$(1)/usr/bin

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/zabbix_$(2) \
		$(1)/usr/bin/
endef

define Package/zabbix3/install/etc
	$(INSTALL_DIR) \
		$(1)/etc/config

	$(INSTALL_DIR) \
		$(1)/etc/zabbix_$(2).conf.d

	$(INSTALL_CONF) \
		$(PKG_INSTALL_DIR)/etc/zabbix_$(2).conf \
		$(1)/etc/

	@echo Include=/etc/zabbix_$(2).conf.d/ >$(1)/etc/zabbix_$(2).conf
	@echo Include=/var/run/zabbix_$(2).conf.d/ >>$(1)/etc/zabbix_$(2).conf
	@echo PidFile=/var/run/zabbix_$(2).pid >>$(1)/etc/zabbix_$(2).conf
	@if [ "$(2)" = "proxy" ] || [ "$(2)" = "server" ]; then echo FpingLocation=/usr/bin/fping; echo Fping6Location=/usr/bin/fping6; fi >>$(1)/etc/zabbix_$(2).conf

	$(INSTALL_CONF) \
		./files/zabbix_$(2).config \
		$(1)/etc/config/zabbix_$(2)

endef

define Package/zabbix3/install/init.d
	$(INSTALL_DIR) \
		$(1)/etc/init.d

	$(INSTALL_BIN) \
		./files/zabbix_$(2).init \
		$(1)/etc/init.d/zabbix_$(2)
endef

define Package/zabbix3/install/zabbix.conf.d
	$(INSTALL_DIR) \
		$(1)/etc/zabbix_agentd.conf.d

	$(INSTALL_BIN) \
		./files/$(2) \
		$(1)/etc/zabbix_agentd.conf.d/$(2)
endef

define Package/zabbix3-agentd/conffiles
/etc/zabbix_agentd.conf
/etc/config/zabbix_agentd
endef
define Package/zabbix3-server/conffiles
/etc/zabbix_server.conf
/etc/config/zabbix_server
endef
define Package/zabbix3-proxy/conffiles
/etc/zabbix_proxy.conf
/etc/config/zabbix_proxy
endef

ifdef CONFIG_PACKAGE_zabbix3-extra-mac80211
define Build/Prepare/zabbix3-extra-mac80211
	mkdir -p $(PKG_BUILD_DIR)/zabbix-extra-mac80211
	$(CP) ./files/zabbix_helper_mac80211.c $(PKG_BUILD_DIR)/zabbix-extra-mac80211/
endef

define Build/Compile/zabbix3-extra-mac80211
	$(TARGET_CC) $(TARGET_CFLAGS) $(PKG_BUILD_DIR)/zabbix-extra-mac80211/zabbix_helper_mac80211.c -o $(PKG_BUILD_DIR)/zabbix-extra-mac80211/zabbix_helper_mac80211
endef
endif

define Build/Prepare
	rm -rf $(PKG_BUILD_DIR)/
	mkdir -p $(PKG_BUILD_DIR)/
	$(TAR) -xzf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_BUILD_DIR) --strip 1
	$(Build/Patch)
	$(call Build/Prepare/zabbix3-extra-mac80211)
endef

define Build/Compile
	$(call Build/Compile/Default)
	$(call Build/Compile/zabbix3-extra-mac80211)
endef

define Package/zabbix3-agentd/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/lib/zabbix/agentd
	$(INSTALL_BIN) ./files/zlock.sh $(1)/lib/zabbix/
	$(call Package/zabbix3/install/sbin,$(1),agentd)
	$(call Package/zabbix3/install/etc,$(1),agentd)
	$(call Package/zabbix3/install/init.d,$(1),agentd)
endef

define Package/zabbix3-extra/install
	$(INSTALL_DIR) $(1)/lib/zabbix/$(2)
	$(CP) ./files/$(2).lib.sh $(1)/lib/zabbix/$(2)/functions.sh
	$(INSTALL_CONF) ./files/$(2).config $(1)/lib/zabbix/$(2)/config_uci
endef

define Package/zabbix3-extra-owrt/install
	$(call Package/zabbix3-extra/install,$(1),owrt)
endef

define Package/zabbix3-extra-mac80211/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/lib/zabbix/mac80211
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/zabbix-extra-mac80211/zabbix_helper_mac80211 $(1)/lib/zabbix/mac80211
	chmod 4755 $(1)/lib/zabbix/mac80211/zabbix_helper_mac80211
	$(call Package/zabbix3-extra/install,$(1),mac80211)
endef

define Package/zabbix3-extra-wifi/install
	$(call Package/zabbix3-extra/install,$(1),wifi)
endef

define Package/zabbix3-extra-network/install
	$(call Package/zabbix3-extra/install,$(1),network)
endef

define Package/zabbix3-sender/install
	$(call Package/zabbix3/install/bin,$(1),sender)
endef

define Package/zabbix3-get/install
	$(call Package/zabbix3/install/bin,$(1),get)
endef

define Package/zabbix3-server/install
	$(call Package/zabbix3/install/sbin,$(1),server)
	$(call Package/zabbix3/install/etc,$(1),server)
	$(call Package/zabbix3/install/init.d,$(1),server)
endef

define Package/zabbix3-proxy/install
	$(call Package/zabbix3/install/sbin,$(1),proxy)
	$(call Package/zabbix3/install/etc,$(1),proxy)
	$(call Package/zabbix3/install/init.d,$(1),proxy)
endef

$(eval $(call BuildPackage,zabbix3-agentd))
$(eval $(call BuildPackage,zabbix3-extra-owrt))
$(eval $(call BuildPackage,zabbix3-extra-mac80211))
$(eval $(call BuildPackage,zabbix3-extra-network))
$(eval $(call BuildPackage,zabbix3-extra-wifi))
$(eval $(call BuildPackage,zabbix3-sender))
$(eval $(call BuildPackage,zabbix3-server))
$(eval $(call BuildPackage,zabbix3-proxy))
$(eval $(call BuildPackage,zabbix3-get))

