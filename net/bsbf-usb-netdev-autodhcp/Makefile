# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) 2025-2026 Chester A. Unal <chester.a.unal@arinc9.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=bsbf-usb-netdev-autodhcp
PKG_VERSION:=1

PKG_LICENSE:=AGPL-3.0-or-later
PKG_MAINTAINER:=Chester A. Unal <chester.a.unal@arinc9.com>

include $(INCLUDE_DIR)/package.mk

define Package/bsbf-usb-netdev-autodhcp
  SECTION:=net
  CATEGORY:=Network
  TITLE:=bsbf-usb-netdev-autodhcp
endef

define Package/bsbf-usb-netdev-autodhcp/description
  bsbf-usb-netdev-autodhcp creates a network with a DHCP client using a newly
  created network interface. It uses metric values from 1 to 8.
endef

define Build/Compile
endef

define Package/bsbf-usb-netdev-autodhcp/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/net
	$(INSTALL_BIN) ./files/etc/hotplug.d/net/99-bsbf-usb-netdev-autodhcp $(1)/etc/hotplug.d/net
endef

$(eval $(call BuildPackage,bsbf-usb-netdev-autodhcp))
