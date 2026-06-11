#
# Copyright (C) 2022 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#
include $(TOPDIR)/rules.mk

PKG_NAME:=basicstation
PKG_VERSION:=2.0.6
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/lorabasics/basicstation/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=7e285de94bae1174b4c3496fc3ab15fe67c72f92c0693d2320bafc654a9dfb43

PKG_MAINTAINER:=Marcus Schref <mschref@tdt.de>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=sx1302_hal mbedtls

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/basicstation
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=LoRaWAN
  TITLE:=LoRa Basic Station
  DEPENDS:=+kmod-usb-acm
endef

define Package/basicstation/description
  LoRa Basic Station. The LoRaWAN Gateway Software.
endef

define Package/basicstation/conffiles
/etc/config/basicstation
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	rm -rf $(PKG_BUILD_DIR)/deps/
	rm -f $(PKG_BUILD_DIR)/makefile
	rm -f $(PKG_BUILD_DIR)/makefile.s2core
	rm -f $(PKG_BUILD_DIR)/setup.gmk
endef

define Package/basicstation/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/station $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/basicstation $(1)/etc/config/basicstation
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/basicstation $(1)/etc/init.d/basicstation
endef

$(eval $(call BuildPackage,basicstation))
