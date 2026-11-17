#
# Copyright (C) 2022 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#
include $(TOPDIR)/rules.mk

PKG_NAME:=sx1302_hal
PKG_VERSION:=2.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Lora-net/sx1302_hal/tar.gz/V$(PKG_VERSION)?
PKG_HASH:=4b62aa6a83ad449c68fdd844fc35024586c9faabca3c5a90a2544735b380de5b

PKG_MAINTAINER:=Marcus Schref <mschref@tdt.de>
PKG_LICENSE:=MIT BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.TXT

include $(INCLUDE_DIR)/package.mk

define Package/sx1302_hal/Default
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=IoT
  TITLE:=SX1302/SX1303 HAL
endef

define Package/sx1302_hal-tests
  $(call Package/sx1302_hal/Default)
  TITLE+=(Tests)
  DEPENDS:=+kmod-usb-acm
endef

define Package/sx1302_hal-tests/description
  Tests for SX1302/SX1303 Hardware Abstraction Layer
endef

define Package/sx1302_hal-utils
  $(call Package/sx1302_hal/Default)
  TITLE+=(Utilities)
  DEPENDS:=+kmod-usb-acm
endef

define Package/sx1302_hal-utils/description
  Utilities for SX1302/SX1303 Hardware Abstraction Layer
endef

CFLAGS = $(TARGET_CFLAGS)

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/libtools \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(ARCH)"

	$(MAKE) -C $(PKG_BUILD_DIR)/libloragw \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(ARCH)"

	$(MAKE) -C $(PKG_BUILD_DIR)/util_boot \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(ARCH)"

	$(MAKE) -C $(PKG_BUILD_DIR)/util_chip_id \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(ARCH)"

	$(MAKE) -C $(PKG_BUILD_DIR)/util_net_downlink \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(ARCH)"

	$(MAKE) -C $(PKG_BUILD_DIR)/util_spectral_scan \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(ARCH)"
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/libtools/inc/tinymt32.h $(1)/usr/include

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libtools/libtinymt32.a $(1)/usr/lib

	$(INSTALL_DIR) $(1)/usr/include/lgw
	$(CP) $(PKG_BUILD_DIR)/libloragw/inc/*.h $(1)/usr/include/lgw

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libloragw/*.a $(1)/usr/lib
endef

define Package/sx1302_hal-tests/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libloragw/test* $(1)/usr/bin
endef

define Package/sx1302_hal-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/util_boot/boot $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/util_chip_id/chip_id $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/util_net_downlink/net_downlink \
		$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/util_spectral_scan/spectral_scan \
		$(1)/usr/bin
endef

$(eval $(call BuildPackage,sx1302_hal-tests))
$(eval $(call BuildPackage,sx1302_hal-utils))
