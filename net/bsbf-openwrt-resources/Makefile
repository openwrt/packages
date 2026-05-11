# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) 2025-2026 Chester A. Unal <chester.a.unal@arinc9.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=bsbf-openwrt-resources
PKG_VERSION:=4

PKG_LICENSE:=AGPL-3.0-or-later
PKG_MAINTAINER:=Chester A. Unal <chester.a.unal@arinc9.com>

include $(INCLUDE_DIR)/package.mk

define Package/bsbf-autoconf-cellular
  SECTION:=net
  CATEGORY:=Network
  TITLE:=bsbf-autoconf-cellular
  URL:=https://github.com/bondingshouldbefree/
endef

define Package/bsbf-autoconf-cellular/description
  bsbf-autoconf-cellular creates a network with MBIM or QMI protocol using a
  newly created network interface. It uses metric values from 1 to 8.
endef

define Package/bsbf-autoconf-dhcp
  SECTION:=net
  CATEGORY:=Network
  TITLE:=bsbf-autoconf-dhcp
  URL:=https://github.com/bondingshouldbefree/
endef

define Package/bsbf-autoconf-dhcp/description
  bsbf-autoconf-dhcp creates a network with a DHCP client using a newly created
  network interface. It uses metric values from 1 to 8.
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

$(eval $(call BuildPackage,bsbf-autoconf-cellular))
$(eval $(call BuildPackage,bsbf-autoconf-dhcp))
