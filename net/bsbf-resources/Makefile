# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) 2025-2026 Chester A. Unal <chester.a.unal@arinc9.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=bsbf-resources
PKG_RELEASE:=1

PKG_LICENSE:=AGPL-3.0-or-later
PKG_MAINTAINER:=Chester A. Unal <chester.a.unal@arinc9.com>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/bondingshouldbefree/bsbf-resources.git
PKG_SOURCE_DATE:=2026-05-16
PKG_SOURCE_VERSION:=733d3159e4c769a4fdd9e42ced53e346e2582beb
PKG_MIRROR_HASH:=95c51a6b430f7b68e0b17d581fda7ac524d5e21e66375fdd4d4f830c61b2089a

include $(INCLUDE_DIR)/package.mk

define Package/bsbf-bonding
  SECTION:=net
  CATEGORY:=Network
  TITLE:=bsbf-bonding
  URL:=https://github.com/bondingshouldbefree/
  DEPENDS:=+bsbf-client-web +bsbf-mptcp +bsbf-rate-limiting +xray-core
endef

define Package/bsbf-bonding/description
  bsbf-bonding configures the system for the BondingShouldBeFree bonding
  solution client.
endef

define Package/bsbf-client-web
  SECTION:=net
  CATEGORY:=Network
  TITLE:=bsbf-client-web
  URL:=https://github.com/bondingshouldbefree/
  DEPENDS:=+curl +uhttpd
endef

define Package/bsbf-mptcp
  SECTION:=net
  CATEGORY:=Network
  TITLE:=bsbf-mptcp
  URL:=https://github.com/bondingshouldbefree/
  DEPENDS:=+curl +fping +ip-full +mptcpize
endef

define Package/bsbf-netspeed
  SECTION:=net
  CATEGORY:=Network
  TITLE:=bsbf-netspeed
  URL:=https://github.com/bondingshouldbefree/
endef

define Package/bsbf-quectel-usbnet
  SECTION:=net
  CATEGORY:=Network
  TITLE:=bsbf-quectel-usbnet
  URL:=https://github.com/bondingshouldbefree/
endef

define Package/bsbf-rate-limiting
  SECTION:=net
  CATEGORY:=Network
  TITLE:=bsbf-rate-limiting
  URL:=https://github.com/bondingshouldbefree/
  DEPENDS:=+tc
endef

define Build/Compile
endef

define Package/bsbf-bonding/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/bsbf-bonding-nft $(1)/etc/init.d

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/99-bsbf-bonding $(1)/etc/uci-defaults

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/usr/sbin/bsbf-bonding $(1)/usr/sbin

	$(INSTALL_DIR) $(1)/usr/share/bsbf
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/resources-client/bsbf_bonding.nft $(1)/usr/share/bsbf
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/resources-client/xray.json $(1)/usr/share/bsbf
endef

define Package/bsbf-client-web/install
	$(INSTALL_DIR) $(1)/www/bsbf-client-web
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/resources-client/bsbf-client-web/index.html $(1)/www/bsbf-client-web
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/resources-client/bsbf-client-web/index.js $(1)/www/bsbf-client-web
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/resources-client/bsbf-client-web/styles.css $(1)/www/bsbf-client-web

	$(INSTALL_DIR) $(1)/www/cgi-bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/resources-client/bsbf-client-web/cgi-bin/bsbf-client-web $(1)/www/cgi-bin
endef

define Package/bsbf-mptcp/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/bsbf-mptcp $(1)/etc/init.d

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/resources-client/bsbf-mptcp $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/resources-client/bsbf-mptcp-helper $(1)/usr/sbin
endef

define Package/bsbf-netspeed/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/resources-client/bsbf-netspeed $(1)/usr/sbin
endef

define Package/bsbf-quectel-usbnet/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/bsbf-quectel-usbnet $(1)/etc/init.d

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/resources-client/bsbf-quectel-usbnet $(1)/usr/sbin
endef

define Package/bsbf-rate-limiting/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/resources-client/bsbf-rate-limiting $(1)/usr/sbin
endef

$(eval $(call BuildPackage,bsbf-bonding))
$(eval $(call BuildPackage,bsbf-client-web))
$(eval $(call BuildPackage,bsbf-mptcp))
$(eval $(call BuildPackage,bsbf-netspeed))
$(eval $(call BuildPackage,bsbf-quectel-usbnet))
$(eval $(call BuildPackage,bsbf-rate-limiting))
