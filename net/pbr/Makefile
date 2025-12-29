# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright 2017-2025 MOSSDeF, Stan Grishin (stangri@melmac.ca).

include $(TOPDIR)/rules.mk

PKG_NAME:=pbr
PKG_VERSION:=1.2.1
PKG_RELEASE:=45
PKG_LICENSE:=AGPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>

include $(INCLUDE_DIR)/package.mk

define Package/pbr
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Routing and Redirection
	TITLE:=Policy Based Routing Service with nft/nft set support
	URL:=https://github.com/stangri/pbr/
	DEPENDS:=+ip-full +jshn +jsonfilter +resolveip
	DEPENDS+=+!BUSYBOX_DEFAULT_AWK:gawk
	DEPENDS+=+!BUSYBOX_DEFAULT_GREP:grep
	DEPENDS+=+!BUSYBOX_DEFAULT_SED:sed
	DEPENDS+=+kmod-nft-core +kmod-nft-nat +nftables-json
	PKGARCH:=all
endef

define Package/pbr/description
	This service enables policy-based routing for WAN interfaces and various VPN tunnels.
	This version supports OpenWrt (23.05 and newer) with firewall4/nft.
endef

define Package/pbr/conffiles
/etc/config/pbr
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/pbr/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/pbr $(1)/etc/init.d/pbr
	$(SED) "s|^\(readonly PKG_VERSION\).*|\1='$(PKG_VERSION)-r$(PKG_RELEASE)'|" $(1)/etc/init.d/pbr
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/pbr $(1)/etc/config/pbr
	$(INSTALL_DIR) $(1)/usr/share/pbr
	$(INSTALL_DATA) ./files/usr/share/pbr/.keep $(1)/usr/share/pbr/.keep
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.user.dnsprefetch $(1)/usr/share/pbr/pbr.user.dnsprefetch
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.user.aws $(1)/usr/share/pbr/pbr.user.aws
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.user.netflix $(1)/usr/share/pbr/pbr.user.netflix
	$(INSTALL_DIR) $(1)/usr/share/nftables.d
	$(CP) ./files/usr/share/nftables.d/* $(1)/usr/share/nftables.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/90-pbr $(1)/etc/uci-defaults/90-pbr
	$(INSTALL_BIN) ./files/etc/uci-defaults/91-pbr-nft $(1)/etc/uci-defaults/91-pbr-nft
	$(INSTALL_BIN) ./files/etc/uci-defaults/99-pbr-version $(1)/etc/uci-defaults/99-pbr-version
endef

define Package/pbr/postinst
#!/bin/sh
# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/pbr netifd check && {
		echo -n "Reinstalling pbr netifd integration... "
		/etc/init.d/pbr netifd install >/dev/null 2>&1 && echo "OK" || echo "FAIL"
	}
	echo -n "Installing rc.d symlink for pbr... "
	/etc/init.d/pbr enable && echo "OK" || echo "FAIL"
fi
exit 0
endef

define Package/pbr/prerm
#!/bin/sh
# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then
	echo -n "Stopping pbr service... "
	/etc/init.d/pbr stop >/dev/null 2>&1 && echo "OK" || echo "FAIL"
	echo -n "Removing rc.d symlink for pbr... "
	/etc/init.d/pbr disable && echo "OK" || echo "FAIL"
	/etc/init.d/pbr netifd check && {
		echo -n "Uninstalling pbr netifd integration... "
		/etc/init.d/pbr netifd uninstall >/dev/null 2>&1 && echo "OK" || echo "FAIL"
	}
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

$(eval $(call BuildPackage,pbr))
