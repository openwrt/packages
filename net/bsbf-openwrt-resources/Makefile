# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) 2025-2026 Chester A. Unal <chester.a.unal@arinc9.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=bsbf-openwrt-resources
PKG_VERSION:=3

PKG_LICENSE:=AGPL-3.0-or-later
PKG_MAINTAINER:=Chester A. Unal <chester.a.unal@arinc9.com>

include $(INCLUDE_DIR)/package.mk

define Package/bsbf-autoconf-cellular
  SECTION:=net
  CATEGORY:=Network
  TITLE:=bsbf-autoconf-cellular
endef

define Package/bsbf-autoconf-cellular/description
  bsbf-autoconf-cellular creates a network with MBIM or QMI protocol using a
  newly created network interface. It uses metric values from 1 to 8.
endef

define Package/bsbf-autoconf-dhcp
  SECTION:=net
  CATEGORY:=Network
  TITLE:=bsbf-autoconf-dhcp
endef

define Package/bsbf-autoconf-dhcp/description
  bsbf-autoconf-dhcp creates a network with a DHCP client using a newly created
  network interface. It uses metric values from 1 to 8.
endef

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

define Package/bsbf-autoconf-cellular/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/net
	$(INSTALL_BIN) ./files/etc/hotplug.d/net/99-bsbf-autoconf-cellular $(1)/etc/hotplug.d/net
endef

define Package/bsbf-autoconf-dhcp/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/net
	$(INSTALL_BIN) ./files/etc/hotplug.d/net/99-bsbf-autoconf-dhcp $(1)/etc/hotplug.d/net
endef

define Package/bsbf-bonding/install
	$(INSTALL_DIR) $(1)/etc/nftables.d
	$(INSTALL_DATA) ./files/etc/nftables.d/99-bsbf-bonding.nft $(1)/etc/nftables.d

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/99-bsbf-bonding $(1)/etc/uci-defaults
endef

$(eval $(call BuildPackage,bsbf-autoconf-cellular))
$(eval $(call BuildPackage,bsbf-autoconf-dhcp))
$(eval $(call BuildPackage,bsbf-bonding))
