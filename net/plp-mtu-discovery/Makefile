# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) 2026 Chester A. Unal <chester.a.unal@arinc9.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=plp-mtu-discovery
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Chester A. Unal <chester.a.unal@arinc9.com>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/bondingshouldbefree/plp-mtu-discovery.git
PKG_SOURCE_DATE:=2026-03-11
PKG_SOURCE_VERSION:=af8296d0be92014ba379b7ee199f7e2f6f21b240
PKG_MIRROR_HASH:=b83a24f584011a538ddc48954649e74eab0faca91d19b40526c265776e8a7e41

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
