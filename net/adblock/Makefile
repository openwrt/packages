#
# Copyright (c) 2015-2018 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=adblock
PKG_VERSION:=3.5.5
PKG_RELEASE:=2
PKG_LICENSE:=GPL-3.0+
PKG_MAINTAINER:=Dirk Brenken <dev@brenken.org>

include $(INCLUDE_DIR)/package.mk

define Package/adblock
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Powerful adblock script to block ad/abuse domains by using DNS
	DEPENDS:=+jshn +jsonfilter
	PKGARCH:=all
endef

define Package/adblock/description
Powerful adblock script to block ad/abuse domains via dnsmasq, unbound, named, kresd or dnscrypt-proxy.
The script supports many domain blacklist sites plus manual black- and whitelist overrides.
Please see https://github.com/openwrt/packages/blob/master/net/adblock/files/README.md for further information.

endef

define Package/adblock/conffiles
/etc/config/adblock
/etc/adblock/adblock.whitelist
/etc/adblock/adblock.blacklist
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/adblock/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/adblock.sh $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/adblock.init $(1)/etc/init.d/adblock

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/adblock.conf $(1)/etc/config/adblock

	$(INSTALL_DIR) $(1)/etc/adblock
	$(INSTALL_CONF) ./files/adblock.notify $(1)/etc/adblock/
	$(INSTALL_CONF) ./files/adblock.blacklist $(1)/etc/adblock/
	$(INSTALL_CONF) ./files/adblock.whitelist $(1)/etc/adblock/
endef

$(eval $(call BuildPackage,adblock))
