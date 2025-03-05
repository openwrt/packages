# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2021 Simon Polack <spolack+git@@mailbox.org>
#

include $(TOPDIR)/rules.mk

PKG_NAME:=airos-dfs-reset
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_MAINTAINER:=Simon Polack <spolack+git@mailbox.org>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/airos-dfs-reset
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Companion app for Ubiquity AirOS to help with DFS
  PKGARCH:=all
  EXTRA_DEPENDS:=dropbear
endef

define Package/airos-dfs-reset/description
Companion app for Ubiquity AirOS Gear to enforce fallback to original frequency after DFS event is over.
It works by soft-rebooting if running-frequency doesnt match the configured frequency.
endef

define Package/airos-dfs-reset/conffiles
/etc/config/airos-dfs-reset
endef

define Build/Compile
endef

define Package/airos-dfs-reset/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/airos-dfs-reset.init $(1)/etc/init.d/airos-dfs-reset
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/airos-dfs-reset $(1)/usr/bin/airos-dfs-reset
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/airos-dfs-reset.config $(1)/etc/config/airos-dfs-reset
endef

$(eval $(call BuildPackage,airos-dfs-reset))
