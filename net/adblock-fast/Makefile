# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright 2023-2025 MOSSDeF, Stan Grishin (stangri@melmac.ca).

include $(TOPDIR)/rules.mk

PKG_NAME:=adblock-fast
PKG_VERSION:=1.1.4
PKG_RELEASE:=14
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_LICENSE:=AGPL-3.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/adblock-fast
  SECTION:=net
  CATEGORY:=Network
  TITLE:=AdBlock Fast Service
  URL:=https://github.com/stangri/adblock-fast/
  DEPENDS:=+jshn +curl
	DEPENDS+=+!BUSYBOX_DEFAULT_AWK:gawk
	DEPENDS+=+!BUSYBOX_DEFAULT_GREP:grep
	DEPENDS+=+!BUSYBOX_DEFAULT_SED:sed
	DEPENDS+=+!BUSYBOX_DEFAULT_SORT:coreutils-sort
  PKGARCH:=all
endef

define Package/adblock-fast/description
Fast AdBlocking script to block ad or abuse/malware domains with Dnsmasq, SmartDNS or Unbound.
Script supports local/remote list of domains and hosts-files for both block-listing and allow-listing.
Please see https://docs.openwrt.melmac.ca/adblock-fast/ for more information.
endef

define Package/adblock-fast/conffiles
/etc/config/adblock-fast
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/adblock-fast/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/adblock-fast $(1)/etc/init.d/adblock-fast
	$(SED) "s|^\(readonly PKG_VERSION\).*|\1='$(PKG_VERSION)-r$(PKG_RELEASE)'|" $(1)/etc/init.d/adblock-fast
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/adblock-fast $(1)/etc/config/adblock-fast
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/90-adblock-fast $(1)/etc/uci-defaults/90-adblock-fast
endef

define Package/adblock-fast/postinst
#!/bin/sh
# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/adblock-fast enable
fi
exit 0
endef

define Package/adblock-fast/prerm
#!/bin/sh
# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then
	echo -n "Stopping adblock-fast service... "
	{ /etc/init.d/adblock-fast stop && \
	  /etc/init.d/adblock-fast killcache; } >/dev/null 2>&1 && echo "OK" || echo "FAIL"
	echo -n "Removing rc.d symlink for adblock-fast... "
	/etc/init.d/adblock-fast disable >/dev/null 2>&1 && echo "OK" || echo "FAIL"
fi
exit 0
endef

$(eval $(call BuildPackage,adblock-fast))
