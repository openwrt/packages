# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2022 - 2026 BlueWave Projects and Services  <licence@blue-wave.net>
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mesh11sd
PKG_VERSION:=7.3.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Rob White <rob@blue-wave.net>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/opennds/mesh11sd/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=c0edda6913b32730c3a208b40a8bacb598a756aa28fe6d5ebaf11a6606ffbcbe

include $(INCLUDE_DIR)/package.mk

define Package/mesh11sd
  SUBMENU:=Mesh
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Dynamic 802.11s Mesh Management Daemon
  PKGARCH:=all
  URL:=https://github.com/opennds/mesh11sd
endef

define Package/mesh11sd/description
  Mesh11sd autonomously manages all aspects of an 802.11s mesh network.
  It functions as a service daemon.
  Mesh parameters are dynamically set across all nodes.
  Island Mesh zones, contiguous mesh backhaul zones
  that are out of range of each other but joined by cable
  or other non-mesh media, are fully supported.
  Multiple upstream portals can be connected,
  giving load balancing on a peer basis with automatic failover.
  Access Point usage data is collected in a central database
  accessible in json format via a CLI command.
  An optional Customer/Client Premises Equipment (CPE) mode
  is provided for use in community WISP projects.
endef

define Package/mesh11sd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mesh11sd $(1)/usr/sbin
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/linux_openwrt/mesh11sd/files/etc/config/mesh11sd $(1)/etc/config/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/linux_openwrt/mesh11sd/files/etc/init.d/mesh11sd $(1)/etc/init.d/
endef

define Package/mesh11sd/conffiles
/etc/config/mesh11sd
endef

define Build/Compile
endef

$(eval $(call BuildPackage,mesh11sd))
