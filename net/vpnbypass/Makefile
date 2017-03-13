# Copyright (c) 2017 Stan Grishin (stangri@melmac.net)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=vpnbypass
PKG_VERSION:=1.3.0
PKG_RELEASE:=3
PKG_LICENSE:=GPL-3.0+
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>

include $(INCLUDE_DIR)/package.mk

define Package/vpnbypass
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+ip-full +ipset +iptables +ubox +dnsmasq-full
	CONFLICTS:=ip dnsmasq
	TITLE:=Simple VPN Bypass Service
	PKGARCH:=all
endef

define Package/vpnbypass/description
This service can be used to enable simple VPN split tunnelling.
Supports accessing domains, IP ranges outside of your VPN tunnel.
Also supports dedicating local ports/IP ranges for direct internet access (outside of your VPN tunnel).
Please see the README for further information.
endef

define Package/vpnbypass/conffiles
/etc/config/vpnbypass
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)/files/
	$(CP) ./files/vpnbypass.init $(PKG_BUILD_DIR)/files/vpnbypass.init
	sed -i "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(PKG_BUILD_DIR)/files/vpnbypass.init
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/vpnbypass/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/vpnbypass.init $(1)/etc/init.d/vpnbypass
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/vpnbypass.conf $(1)/etc/config/vpnbypass
	$(INSTALL_DIR) $(1)/etc/hotplug.d/firewall
	$(INSTALL_DATA) ./files/vpnbypass.hotplug $(1)/etc/hotplug.d/firewall/94-vpnbypass
endef

$(eval $(call BuildPackage,vpnbypass))
