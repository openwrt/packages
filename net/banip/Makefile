# banIP - ban incoming and outgoing IPs via named nftables Sets
# Copyright (c) 2018-2024 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=banip
PKG_VERSION:=1.0.0
PKG_RELEASE:=4
PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Dirk Brenken <dev@brenken.org>

include $(INCLUDE_DIR)/package.mk

define Package/banip
	SECTION:=net
	CATEGORY:=Network
	TITLE:=banIP blocks IPs via named nftables Sets
	DEPENDS:=+jshn +jsonfilter +firewall4 +ca-bundle +rpcd +rpcd-mod-rpcsys
	PKGARCH:=all
endef

define Package/banip/description
banIP blocks IPs via named nftables Sets.
banIP supports many IP blocklist feeds and provides a log service to block suspicious IPs in realtime.
Please see https://github.com/openwrt/packages/blob/master/net/banip/files/README.md for further information.

endef

define Package/banip/conffiles
/etc/config/banip
/etc/banip/banip.allowlist
/etc/banip/banip.blocklist
/etc/banip/banip.custom.feeds
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/banip/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/banip-service.sh $(1)/usr/bin

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/banip.init $(1)/etc/init.d/banip

	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_CONF) ./files/banip-functions.sh $(1)/usr/lib

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/banip.conf $(1)/etc/config/banip

	$(INSTALL_DIR) $(1)/etc/banip
	$(INSTALL_CONF) ./files/banip.tpl $(1)/etc/banip
	$(INSTALL_CONF) ./files/banip.allowlist $(1)/etc/banip
	$(INSTALL_CONF) ./files/banip.blocklist $(1)/etc/banip
	$(INSTALL_CONF) ./files/banip.countries $(1)/etc/banip
	$(INSTALL_CONF) ./files/banip.feeds $(1)/etc/banip
	$(INSTALL_CONF) ./files/banip.custom.feeds $(1)/etc/banip

	$(INSTALL_DIR) $(1)/www/cgi-bin
	$(INSTALL_BIN) ./files/banip.cgi $(1)/www/cgi-bin/banip
endef

$(eval $(call BuildPackage,banip))
