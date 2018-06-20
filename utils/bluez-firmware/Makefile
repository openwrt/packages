#
# Copyright (C) 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bluez-firmware
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/RPi-Distro/bluez-firmware.git
PKG_SOURCE_DATE:=2018-06-15
PKG_SOURCE_VERSION:=ade2bae1aaaebede09abb8fb546f767a0e4c7804
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Matej Kupljen <matej@cloudmondo.com>

include $(INCLUDE_DIR)/package.mk

define Package/bluez-firmware
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=$(PKG_SOURCE_URL)
  TITLE:=BlueZ Firmware
  DEPENDS:=
endef

define Package/bluez-firmware/compile
endef

define Package/bluez-firmware/install
	$(INSTALL_DIR) $(1)/lib/firmware/brcm
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/broadcom/*.bin $(1)/lib/firmware/brcm
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/broadcom/*.hex $(1)/lib/firmware/brcm
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/broadcom/*.hcd $(1)/lib/firmware/brcm
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/broadcom/BCM-LEGAL.txt $(1)/lib/firmware/brcm
endef

$(eval $(call BuildPackage,bluez-firmware))

