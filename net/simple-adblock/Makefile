# Copyright 2017-2018 Stan Grishin (stangri@melmac.net)
# TLD optimization written by Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=simple-adblock
PKG_VERSION:=1.6.3
PKG_RELEASE:=5
PKG_LICENSE:=GPL-3.0+
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>

include $(INCLUDE_DIR)/package.mk

define Package/simple-adblock
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Simple AdBlock Service
	PKGARCH:=all
endef

define Package/simple-adblock/description
This service provides dnsmasq-based ad blocking.
Please see the README for further information.

endef

define Package/simple-adblock/conffiles
/etc/config/simple-adblock
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)/files/
	$(CP) ./files/simple-adblock.init $(PKG_BUILD_DIR)/files/simple-adblock.init
	sed -i "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(PKG_BUILD_DIR)/files/simple-adblock.init
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/simple-adblock/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/simple-adblock.init $(1)/etc/init.d/simple-adblock
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/simple-adblock.conf $(1)/etc/config/simple-adblock
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/simple-adblock.hotplug $(1)/etc/hotplug.d/iface/80-simple-adblock
endef

define Package/simple-adblock/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		/etc/init.d/simple-adblock enable
		while uci -q del ucitrack.@simple-adblock[-1]; do :; done
		uci -q batch <<-EOF >/dev/null
			add ucitrack simple-adblock
			set ucitrack.@simple-adblock[0].init='simple-adblock'
			commit ucitrack
	EOF
	fi
	exit 0
endef

define Package/simple-adblock/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		while uci -q del ucitrack.@simple-adblock[-1]; do :; done
		echo "Stopping service and removing rc.d symlink for simple-adblock"
		/etc/init.d/simple-adblock stop || true
		/etc/init.d/simple-adblock killcache || true
		/etc/init.d/simple-adblock disable || true
	fi
	exit 0
endef

$(eval $(call BuildPackage,simple-adblock))
