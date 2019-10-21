# Copyright 2017-2018 Stan Grishin (stangri@melmac.net)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=vpnbypass
PKG_VERSION:=1.3.1
PKG_RELEASE:=4
PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>

include $(INCLUDE_DIR)/package.mk

define Package/vpnbypass
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+ipset +iptables
	CONFLICTS:=vpn-policy-routing
	TITLE:=VPN Bypass Service
	PKGARCH:=all
endef

define Package/vpnbypass/description
This service can be used to enable simple VPN split tunnelling.
Supports accessing domains, IP ranges outside of your VPN tunnel.
Also supports dedicating local ports/IP ranges for direct
internet access (outside of your VPN tunnel).
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


define Package/vpnbypass/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		/etc/init.d/vpnbypass enable

		while uci -q del ucitrack.@vpnbypass[-1]; do :; done

		uci -q batch <<-EOF >/dev/null
			add ucitrack vpnbypass
			set ucitrack.@vpnbypass[0].init='vpnbypass'
			del_list ucitrack.@firewall[0].affects='vpnbypass'
			add_list ucitrack.@firewall[0].affects='vpnbypass'
			commit ucitrack
	EOF
	fi
	exit 0
endef

define Package/vpnbypass/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		while uci -q delete ucitrack.@vpnbypass[-1]; do :; done
		uci -q del_list ucitrack.@firewall[0].affects='vpnbypass'
		echo "Stopping service and removing rc.d symlink for vpnbypass"
		/etc/init.d/vpnbypass stop || true
		/etc/init.d/vpnbypass disable || true
	fi
	exit 0
endef

$(eval $(call BuildPackage,vpnbypass))
