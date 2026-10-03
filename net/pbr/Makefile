# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright 2017-2026 MOSSDeF, Stan Grishin (stangri@melmac.ca).

include $(TOPDIR)/rules.mk

PKG_NAME:=pbr
PKG_VERSION:=1.2.4
PKG_RELEASE:=0
PKG_LICENSE:=AGPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>, Erik Conijn <egc112@msn.com>

include $(INCLUDE_DIR)/package.mk

define Package/pbr
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=Policy Based Routing Service with nft/nft set support
  URL:=https://github.com/mossdef-org/pbr/
  PKGARCH:=all
  DEPENDS:= \
	+ip-full \
	+jshn \
	+jsonfilter \
	+resolveip \
	+ucode \
	+ucode-mod-fs \
	+ucode-mod-uci \
	+ucode-mod-ubus \
	+!BUSYBOX_DEFAULT_AWK:gawk \
	+!BUSYBOX_DEFAULT_GREP:grep \
	+!BUSYBOX_DEFAULT_SED:sed \
	+kmod-nft-core \
	+kmod-nft-nat \
	+nftables-json
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
	$(INSTALL_DIR) $(1)/lib/pbr
	$(INSTALL_DATA) ./files/lib/pbr/pbr.uc $(1)/lib/pbr/pbr.uc
	$(INSTALL_DATA) ./files/lib/pbr/pkg.uc $(1)/lib/pbr/pkg.uc
	$(INSTALL_DATA) ./files/lib/pbr/cli.uc $(1)/lib/pbr/cli.uc
	$(INSTALL_DATA) ./files/lib/pbr/sys.uc $(1)/lib/pbr/sys.uc
	$(INSTALL_DATA) ./files/lib/pbr/validators.uc $(1)/lib/pbr/validators.uc
	$(INSTALL_DATA) ./files/lib/pbr/output.uc $(1)/lib/pbr/output.uc
	$(INSTALL_DATA) ./files/lib/pbr/config.uc $(1)/lib/pbr/config.uc
	$(INSTALL_DATA) ./files/lib/pbr/platform.uc $(1)/lib/pbr/platform.uc
	$(INSTALL_DATA) ./files/lib/pbr/network.uc $(1)/lib/pbr/network.uc
	$(INSTALL_DATA) ./files/lib/pbr/nft.uc $(1)/lib/pbr/nft.uc
	$(SED) "s|^\(\tversion:\).*|\1 '$(PKG_VERSION)-r$(PKG_RELEASE)',|" $(1)/lib/pbr/pkg.uc
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/pbr $(1)/etc/config/pbr
	$(INSTALL_DIR) $(1)/usr/share/pbr
	$(INSTALL_DATA) ./files/usr/share/pbr/.keep $(1)/usr/share/pbr/.keep
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.user.dnsprefetch $(1)/usr/share/pbr/pbr.user.dnsprefetch
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.user.aws.uc $(1)/usr/share/pbr/pbr.user.aws.uc
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.user.netflix.uc $(1)/usr/share/pbr/pbr.user.netflix.uc
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/90-pbr $(1)/etc/uci-defaults/90-pbr
endef

define Package/pbr/postinst
#!/bin/sh
# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/pbr netifd check && {
		echo -n "Reinstalling pbr netifd integration... "
		/etc/init.d/pbr netifd install >/dev/null 2>&1 && echo "OK" || echo "FAIL"
	}
fi
exit 0
endef

define Package/pbr/prerm
#!/bin/sh
# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then
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
