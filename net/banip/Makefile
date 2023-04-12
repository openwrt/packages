#
# banIP - ban incoming and outgoing ip addresses/subnets via sets in nftables
# Copyright (c) 2018-2023 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=banip
PKG_VERSION:=0.8.3
PKG_RELEASE:=2
PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Dirk Brenken <dev@brenken.org>

include $(INCLUDE_DIR)/package.mk

define Package/banip
	SECTION:=net
	CATEGORY:=Network
	TITLE:=banIP blocks IP addresses via named nftables sets
	DEPENDS:=+jshn +jsonfilter +firewall4 +ca-bundle +logd +rpcd +rpcd-mod-rpcsys
	PKGARCH:=all
endef

define Package/banip/description
banIP blocks IP addresses via named nftables sets.
banIP supports many IP blocklist feeds and provides a log service to block suspicious IPs in realtime.
Please see https://github.com/openwrt/packages/blob/master/net/banip/files/README.md for further information.

endef

define Package/banip/conffiles
/etc/config/banip
/etc/banip/banip.allowlist
/etc/banip/banip.blocklist
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
endef

$(eval $(call BuildPackage,banip))
