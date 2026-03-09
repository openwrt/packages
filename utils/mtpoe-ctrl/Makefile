#
# Copyright (C) 2018 adron@yapic.net
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mtpoe-ctrl
PKG_VERSION:=1.15
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/adron-s/mtpoe_ctrl
PKG_SOURCE_VERSION:=9c42b74274cca10810363dbbb6d161bfb9cedb7e
PKG_MIRROR_HASH:=8a8ecc631460305cee62c609a551e7bcc70da2f95298e626c6b94ae26afa6b4f

PKG_MAINTAINER:=Sergey Sergeev <adron@yapic.net>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/mtpoe-ctrl
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libuci +kmod-spi-dev
  TITLE:=Management utility for MikroTik PoE V2/V3/V4
  URL:=$(PKG_SOURCE_URL)
endef

define Package/mtpoe-ctrl/description
  Controls PoE output ports on MikroTik RB5009UPr via SPI interface.
  Supports PoE protocol V2/V3/V4.
endef

define Package/mtpoe-ctrl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bins/mtpoe_ctrl $(1)/usr/bin/mtpoe-ctrl
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt/files/99_mtpoe-ctrl $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt/files/99_mtpoe-ctrl.defaults $(1)/etc/uci-defaults/
endef

$(eval $(call BuildPackage,mtpoe-ctrl))
