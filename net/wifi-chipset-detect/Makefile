# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2025-2026 BlueWave Projects and Services  <licence@blue-wave.net>
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wifi-chipset-detect
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Rob White <rob@blue-wave.net>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/opennds/wifi-chipset-detect/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=2e4d60861df598dbb13e0133a7ccaa4efa2534c158ae92852d693791e0f206b7

include $(INCLUDE_DIR)/package.mk

define Package/wifi-chipset-detect
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Wireless
  TITLE:=Wireless Chipset Detection Utility
  PKGARCH:=all
  URL:=https://github.com/opennds/wifi-chipset-detect
endef

define Package/wifi-chipset-detect/description
  Detects WiFi chipset + driver capabilities.
  It is based on the detection code found in the apmond daemon
  incorporated into the OpenNDS and Mesh11sd packages.
  The output is json formatted.
endef

define Package/wifi-chipset-detect/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/wifi-chipset-detect $(1)/usr/sbin
endef

define Build/Compile
endef

$(eval $(call BuildPackage,wifi-chipset-detect))
