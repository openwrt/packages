# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2022 - 2026 BlueWave Projects and Services  <licence@blue-wave.net>
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mesh11sd
PKG_VERSION:=6.2.1
PKG_RELEASE:=2

PKG_MAINTAINER:=Rob White <rob@blue-wave.net>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/opennds/mesh11sd/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=8ee36f12873a4648edc0ba5ac991a93ae79c6cd48940d9b7e999bb845cf78471

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
  It acts as a service daemon.
  Mesh parameters are dynamically set across all nodes.
  Point to multi-point vxlan tunneling is provided by default.
  Custom vlan trunking over the vxlan tunnel is fully supported.
  Cabled sections of backhaul are fully supported.
  Access Point usage data is collected in a central database.
  A command line interface is provided for many functions.
  An optional Customer/Client Premises Equipment (CPE) mode is provided
  CPE mode greatly simplifies rollout of community WISP projects.
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
