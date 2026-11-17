# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) 2026 Chester A. Unal <chester.a.unal@arinc9.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=plp-mtu-discovery
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Chester A. Unal <chester.a.unal@arinc9.com>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/bondingshouldbefree/plp-mtu-discovery.git
PKG_SOURCE_DATE:=2026-03-16
PKG_SOURCE_VERSION:=452ddcc34c041b0fc6aa85f9102e1a0a0f0080cf
PKG_MIRROR_HASH:=0543d38fe19a360bf0182a616d8c11e3e1f8d0b7e9423ba15ecaf9fdd4375a63

include $(INCLUDE_DIR)/package.mk

define Package/plp-mtu-discovery
  SECTION:=net
  CATEGORY:=Network
  TITLE:=plp-mtu-discovery
endef

define Package/plp-mtu-discovery/description
  Perform Path MTU Discovery without relying on ICMP errors, which are often not
  delivered.
endef

define Package/plp-mtu-discovery/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/plpmtu $(1)/usr/sbin
endef

$(eval $(call BuildPackage,plp-mtu-discovery))
