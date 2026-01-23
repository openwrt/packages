# dns based ad/abuse domain blocking
# Copyright (c) 2015-2026 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=adblock
PKG_VERSION:=4.5.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Dirk Brenken <dev@brenken.org>

include $(INCLUDE_DIR)/package.mk

define Package/adblock
	SECTION:=net
	CATEGORY:=Network
	TITLE:=adblock blocks ad/abuse domains by using DNS
	DEPENDS:=+jshn +jsonfilter +firewall4 +coreutils +coreutils-sort +gawk +ca-bundle +rpcd +rpcd-mod-rpcsys
	PKGARCH:=all
endef

define Package/adblock/description
adblock blocks ad/abuse domains via dnsmasq, unbound, named, smartdns or kresd.
adblock consumes a minimum of memory, is very fast and supports many domain blocklist sites plus local block- and allowlist overrides.
Please see https://github.com/openwrt/packages/blob/master/net/adblock/files/README.md for further information.

endef

define Package/adblock/conffiles
/etc/config/adblock
/etc/adblock/adblock.allowlist
/etc/adblock/adblock.blocklist
/etc/adblock/adblock.custom.feeds
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/adblock/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/adblock.sh $(1)/usr/bin

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/adblock.init $(1)/etc/init.d/adblock

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/adblock.conf $(1)/etc/config/adblock

	$(INSTALL_DIR) $(1)/etc/adblock
	$(INSTALL_BIN) ./files/adblock.mail $(1)/etc/adblock
	$(INSTALL_CONF) ./files/adblock.allowlist $(1)/etc/adblock
	$(INSTALL_CONF) ./files/adblock.blocklist $(1)/etc/adblock
	$(INSTALL_CONF) ./files/adblock.categories $(1)/etc/adblock
	$(INSTALL_CONF) ./files/adblock.feeds $(1)/etc/adblock
	$(INSTALL_CONF) ./files/adblock.custom.feeds $(1)/etc/adblock

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/95-adblock-housekeeping $(1)/etc/uci-defaults
endef

$(eval $(call BuildPackage,adblock))
