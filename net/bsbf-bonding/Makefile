# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) 2025-2026 Chester A. Unal <chester.a.unal@arinc9.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=bsbf-bonding
PKG_VERSION:=1

PKG_LICENSE:=AGPL-3.0-or-later
PKG_MAINTAINER:=Chester A. Unal <chester.a.unal@arinc9.com>

include $(INCLUDE_DIR)/package.mk

define Package/bsbf-bonding
  SECTION:=net
  CATEGORY:=Network
  TITLE:=bsbf-bonding
  DEPENDS:=+bsbf-mptcp +bsbf-route +bsbf-tcp-in-udp +xray-core
endef

define Package/bsbf-bonding/description
  bsbf-bonding configures the system for the BondingShouldBeFree bonding
  solution client.
endef

define Build/Compile
endef

define Package/bsbf-bonding/install
	$(INSTALL_DIR) $(1)/etc/nftables.d
	$(INSTALL_DATA) ./files/etc/nftables.d/99-bsbf-bonding.nft $(1)/etc/nftables.d

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/99-bsbf-bonding $(1)/etc/uci-defaults
endef

$(eval $(call BuildPackage,bsbf-bonding))
