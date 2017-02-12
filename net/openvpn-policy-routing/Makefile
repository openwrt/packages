# Copyright (c) 2017 Stan Grishin (stangri@melmac.net)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=openvpn-policy-routing
PKG_VERSION:=5.0.1
PKG_RELEASE:=10
PKG_LICENSE:=GPL-3.0+
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+ipset +iptables +resolveip +kmod-ipt-ipset
	CONFLICTS:=vpnbypass
	TITLE:=OpenVPN Policy-Based Routing Service
	PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
This service allows policy-based routing for OpenVPN tunnels and WAN interface.
Policies can specify domains, local IPs/subnets and ports, as well as remote IPs/subnets and ports.
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/openvpn-policy-routing
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)/files/
	$(CP) ./files/openvpn-policy-routing.init $(PKG_BUILD_DIR)/files/openvpn-policy-routing.init
	sed -i "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(PKG_BUILD_DIR)/files/openvpn-policy-routing.init
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/openvpn-policy-routing.init $(1)/etc/init.d/openvpn-policy-routing
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/openvpn-policy-routing.conf $(1)/etc/config/openvpn-policy-routing
	$(INSTALL_DIR) $(1)/etc/hotplug.d/firewall
	$(INSTALL_DATA) ./files/openvpn-policy-routing.hotplug $(1)/etc/hotplug.d/firewall/99-openvpn-policy-routing
endef

define Package/$(PKG_NAME)/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "${IPKG_INSTROOT}" ]; then

		while [ ! -z "$(uci -q get ucitrack.@openvpn-policy-routing[-1] 2>/dev/null)" ] ; do
			uci -q delete ucitrack.@openvpn-policy-routing[-1]
		done

		while [ ! -z "$(uci -q get ucitrack.@firewall[-1].affects 2>/dev/null | awk '/openvpn-policy-routing/')" ] ; do
			uci -q del_list ucitrack.@firewall[-1].affects='openvpn-policy-routing'
		done

		uci -q batch <<-EOF >/dev/null
			add ucitrack openvpn-policy-routing
			set ucitrack.@openvpn-policy-routing[-1].init='openvpn-policy-routing'
			add_list ucitrack.@firewall[-1].affects='openvpn-policy-routing'
			commit ucitrack
	EOF
	fi
	exit 0
endef

define Package/$(PKG_NAME)/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Stopping service and removing rc.d symlink for openvpn-policy-routing"
		/etc/init.d/openvpn-policy-routing stop || true
		/etc/init.d/openvpn-policy-routing disable

		while [ ! -z "$(uci -q get ucitrack.@openvpn-policy-routing[-1] 2>/dev/null)" ] ; do
			uci -q delete ucitrack.@openvpn-policy-routing[-1]
		done

		while [ ! -z "$(uci -q get ucitrack.@firewall[-1].affects 2>/dev/null | awk '/openvpn-policy-routing/')" ] ; do
			uci -q del_list ucitrack.@firewall[-1].affects='openvpn-policy-routing'
		done
	fi
	exit 0
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
