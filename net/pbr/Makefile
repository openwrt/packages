# Copyright 2017-2024 MOSSDeF, Stan Grishin (stangri@melmac.ca).
# This is free software, licensed under AGPL-3.0-or-later.

include $(TOPDIR)/rules.mk

PKG_NAME:=pbr
PKG_VERSION:=1.1.7
PKG_RELEASE:=10
PKG_LICENSE:=AGPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>

include $(INCLUDE_DIR)/package.mk

define Package/pbr/default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=Policy Based Routing Service
  URL:=https://github.com/stangri/pbr/
  DEPENDS:=+ip-full +jshn +jsonfilter +resolveip
	DEPENDS+=+!BUSYBOX_DEFAULT_AWK:gawk
	DEPENDS+=+!BUSYBOX_DEFAULT_GREP:grep
	DEPENDS+=+!BUSYBOX_DEFAULT_SED:sed
  PROVIDES:=pbr
  PKGARCH:=all
endef

define Package/pbr
$(call Package/pbr/default)
  TITLE+= with nft/nft set support
  DEPENDS+=+kmod-nft-core +kmod-nft-nat +nftables-json
  VARIANT:=nftables
  DEFAULT_VARIANT:=1
endef

define Package/pbr-netifd
$(call Package/pbr/default)
  TITLE+= with nft/nft set and netifd support
  VARIANT:=netifd
endef

define Package/pbr/default/description
  This service enables policy-based routing for WAN interfaces and various VPN tunnels.
endef

define Package/pbr/description
  $(call Package/pbr/default/description)
  This version supports OpenWrt (23.05 and newer) with firewall4/nft.
endef

define Package/pbr-netifd/description
  $(call Package/pbr/default/description)
  This version supports OpenWrt with (23.05 and newer) firewall4/nft.
  This version uses OpenWrt native netifd/tables to set up interfaces. This is a WIP.
endef

define Package/pbr/default/conffiles
/etc/config/pbr
endef

Package/pbr/conffiles = $(Package/pbr/default/conffiles)
Package/pbr-netifd/conffiles = $(Package/pbr/default/conffiles)

define Build/Configure
endef

define Build/Compile
endef

define Package/pbr/default/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/pbr $(1)/etc/init.d/pbr
	$(SED) "s|^\(readonly PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/pbr
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/pbr $(1)/etc/config/pbr
	$(INSTALL_DIR) $(1)/usr/share/pbr
	$(INSTALL_DATA) ./files/usr/share/pbr/.keep $(1)/usr/share/pbr/.keep
	$(INSTALL_DATA) ./files/usr/share/pbr/firewall.include $(1)/usr/share/pbr/firewall.include
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.user.aws $(1)/usr/share/pbr/pbr.user.aws
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.user.netflix $(1)/usr/share/pbr/pbr.user.netflix
	$(INSTALL_DIR) $(1)/usr/share/nftables.d
	$(CP) ./files/usr/share/nftables.d/* $(1)/usr/share/nftables.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN)  ./files/etc/uci-defaults/90-pbr $(1)/etc/uci-defaults/90-pbr
endef

define Package/pbr/install
$(call Package/pbr/default/install,$(1))
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN)  ./files/etc/uci-defaults/91-pbr-nft $(1)/etc/uci-defaults/91-pbr-nft
endef

define Package/pbr-netifd/install
$(call Package/pbr/default/install,$(1))
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN)  ./files/etc/uci-defaults/91-pbr-netifd $(1)/etc/uci-defaults/91-pbr-netifd
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
		echo -n "Stopping pbr service... "
		/etc/init.d/pbr stop quiet >/dev/null 2>&1 && echo "OK" || echo "FAIL"
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

define Package/pbr-netifd/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		chmod -x /etc/init.d/pbr || true
		fw4 -q reload || true
		chmod +x /etc/init.d/pbr || true
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
		echo -n "Stopping pbr-netifd service... "
		/etc/init.d/pbr stop quiet >/dev/null 2>&1 && echo "OK" || echo "FAIL"
		echo -n "Removing rc.d symlink for pbr... "
		/etc/init.d/pbr disable && echo "OK" || echo "FAIL"
		echo -n "Cleaning up /etc/iproute2/rt_tables... "
		if sed -i '/pbr_/d' /etc/iproute2/rt_tables; then
			echo "OK"
		else
			echo "FAIL"
		fi
		echo -n "Cleaning up /etc/config/network... "
		if sed -i '/ip.table.*pbr_/d' /etc/config/network; then
			echo "OK"
		else
			echo "FAIL"
		fi
		echo -n "Restarting Network... "
		if /etc/init.d/network restart >/dev/null 2>&1; then
			echo "OK"
		else
			echo "FAIL"
		fi
	fi
	exit 0
endef

define Package/pbr-netifd/postrm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		fw4 -q reload || true
	fi
	exit 0
endef

$(eval $(call BuildPackage,pbr))
# $(eval $(call BuildPackage,pbr-netifd))
