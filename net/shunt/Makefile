# shunt - policy based routing via passive DNS observation
# Copyright (c) 2026 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=shunt
PKG_VERSION:=0.1.5
PKG_RELEASE:=2
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=
PKG_MAINTAINER:=Dirk Brenken <dev@brenken.org>

include $(INCLUDE_DIR)/package.mk

define Package/shunt
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Policy based routing via passive DNS observation
  DEPENDS:=+ucode +ucode-mod-fs +ucode-mod-socket +ucode-mod-uci \
  +ucode-mod-uloop +ucode-mod-resolv +ucode-mod-ubus \
  +ucode-mod-rtnl +ucode-mod-log +rpcd-mod-ucode +nftables-json +ip
  PKGARCH:=all
endef

define Package/shunt/description
  Routes traffic by source, destination and domain into policy interfaces.
  Domain addresses are learned resolver-independently: a poll loop resolves the
  configured names and a passive AF_PACKET observer picks every DNS answer off
  the wire, so shunt works unchanged with dnsmasq, unbound or any other backend.
  Marks are applied via an own nftables table with per-element
  counters, routing via fwmark rules and per-policy tables, with gateway
  discovery and interface events from netifd.
endef

define Package/shunt/conffiles
/etc/config/shunt
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/shunt/install
	$(INSTALL_DIR) $(1)/usr/share/ucode/shunt
	$(INSTALL_DATA) ./src/*.uc $(1)/usr/share/ucode/shunt/

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/shunt.uc $(1)/usr/sbin/shunt

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/shunt.init $(1)/etc/init.d/shunt

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/shunt.config $(1)/etc/config/shunt

	$(INSTALL_DIR) $(1)/usr/share/rpcd/ucode
	$(INSTALL_DATA) ./files/shunt.rpcd $(1)/usr/share/rpcd/ucode/shunt

endef

$(eval $(call BuildPackage,shunt))
