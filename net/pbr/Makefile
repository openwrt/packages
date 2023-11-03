# Copyright 2017-2022 Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=pbr
PKG_VERSION:=1.1.1
PKG_RELEASE:=7
PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>

include $(INCLUDE_DIR)/package.mk

define Package/pbr/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=Policy Based Routing Service
  URL:=https://docs.openwrt.melmac.net/pbr/
  DEPENDS:=+ip-full +jshn +jsonfilter +resolveip
  CONFLICTS:=vpnbypass vpn-policy-routing
  PKGARCH:=all
endef

define Package/pbr
$(call Package/pbr/Default)
  TITLE+= with nft/nft set support
  DEPENDS+=+kmod-nft-core +kmod-nft-nat +nftables-json
  VARIANT:=nftables
  PROVIDES:=vpnbypass vpn-policy-routing
  DEFAULT_VARIANT:=1
endef

define Package/pbr-iptables
$(call Package/pbr/Default)
  TITLE+= with iptables/ipset support
  DEPENDS+=+ipset +iptables +kmod-ipt-ipset +iptables-mod-ipopt
  VARIANT:=iptables
  PROVIDES:=pbr
endef

define Package/pbr-netifd
$(call Package/pbr/Default)
  TITLE+= with netifd support
  VARIANT:=netifd
  PROVIDES:=pbr
endef

define Package/pbr/description
This service enables policy-based routing for WAN interfaces and various VPN tunnels.
This version supports OpenWrt with both firewall3/ipset/iptables and firewall4/nft.
endef

define Package/pbr-iptables/description
This service enables policy-based routing for WAN interfaces and various VPN tunnels.
This version supports OpenWrt with firewall3/ipset/iptables.
endef

define Package/pbr-netifd/description
This service enables policy-based routing for WAN interfaces and various VPN tunnels.
This version supports OpenWrt with both firewall3/ipset/iptables and firewall4/nft.
This version uses OpenWrt native netifd/tables to set up interfaces. This is WIP.
endef

define Package/pbr/conffiles
/etc/config/pbr
endef

Package/pbr-iptables/conffiles = $(Package/pbr/conffiles)
Package/pbr-netifd/conffiles = $(Package/pbr/conffiles)

define Build/Configure
endef

define Build/Compile
endef

define Package/pbr/default/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/pbr.init $(1)/etc/init.d/pbr
	$(SED) "s|^\(readonly PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/pbr
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/etc/hotplug.d/iface/70-pbr $(1)/etc/hotplug.d/iface/70-pbr
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN)  ./files/etc/uci-defaults/90-pbr $(1)/etc/uci-defaults/90-pbr
	$(INSTALL_DIR) $(1)/usr/share/pbr
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.user.aws $(1)/usr/share/pbr/pbr.user.aws
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.user.netflix $(1)/usr/share/pbr/pbr.user.netflix
endef

define Package/pbr/install
$(call Package/pbr/default/install,$(1))
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/pbr $(1)/etc/config/pbr
	$(INSTALL_DIR) $(1)/usr/share/pbr
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.firewall.include $(1)/usr/share/pbr/pbr.firewall.include
	$(INSTALL_DIR) $(1)/usr/share/nftables.d
	$(CP) ./files/usr/share/nftables.d/* $(1)/usr/share/nftables.d/
endef

define Package/pbr-iptables/install
$(call Package/pbr/default/install,$(1))
	$(INSTALL_DIR) $(1)/etc/hotplug.d/firewall
	$(INSTALL_DATA) ./files/etc/hotplug.d/firewall/70-pbr $(1)/etc/hotplug.d/firewall/70-pbr
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/pbr.iptables $(1)/etc/config/pbr
endef

define Package/pbr-netifd/install
$(call Package/pbr/default/install,$(1))
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/pbr $(1)/etc/config/pbr
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN)  ./files/etc/uci-defaults/91-pbr $(1)/etc/uci-defaults/91-pbr
endef

define Package/pbr/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		chmod -x /etc/init.d/pbr || true
		fw4 -q reload || true
		chmod +x /etc/init.d/pbr || true
		echo -n "Installing rc.d symlink for pbr... "
		/etc/init.d/pbr enable && echo "OK" || echo "FAIL"
	fi
	exit 0
endef

define Package/pbr/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		uci -q delete firewall.pbr || true
		echo "Stopping pbr service... "
		/etc/init.d/pbr stop && echo "OK" || echo "FAIL"
		echo -n "Removing rc.d symlink for pbr... "
		/etc/init.d/pbr disable && echo "OK" || echo "FAIL"
	fi
	exit 0
endef

define Package/pbr/postrm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		fw4 -q reload || true
	fi
	exit 0
endef

define Package/pbr-iptables/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo -n "Installing rc.d symlink for pbr-iptables... "
		/etc/init.d/pbr enable && echo "OK" || echo "FAIL"
	fi
	exit 0
endef

define Package/pbr-iptables/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		uci -q delete firewall.pbr || true
		echo "Stopping pbr-iptables service... "
		/etc/init.d/pbr stop && echo "OK" || echo "FAIL"
		echo -n "Removing rc.d symlink for pbr-iptables... "
		/etc/init.d/pbr disable && echo "OK" || echo "FAIL"
	fi
	exit 0
endef

define Package/pbr-netifd/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo -n "Installing rc.d symlink for pbr-netifd... "
		/etc/init.d/pbr enable && echo "OK" || echo "FAIL"
	fi
	exit 0
endef

define Package/pbr-netifd/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		uci -q delete firewall.pbr || true
		echo "Stopping pbr-netifd service... "
		/etc/init.d/pbr stop && echo "OK" || echo "FAIL"
		echo -n "Removing rc.d symlink for pbr... "
		/etc/init.d/pbr disable && echo "OK" || echo "FAIL"
	fi
	exit 0
endef

$(eval $(call BuildPackage,pbr))
$(eval $(call BuildPackage,pbr-iptables))
#$(eval $(call BuildPackage,pbr-netifd))
