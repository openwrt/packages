#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=rtl-ais
PKG_VERSION:=20151213

PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/dgiardini/rtl-ais.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=b805be0164475e58a73b57763a8cbbf8a2bd0ded
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=0bf15869935e4496108ade4f7e9c1f7990b11ce53c9c1e0c9e81bc7f082b33b5

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING

PKG_MAINTAINER:=Nuno Goncalves <nunojpg@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/rtl-ais
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=rtl-sdr AIS dual channel tuner
  DEPENDS:=+libpthread +librtlsdr
  URL:=https://github.com/dgiardini/rtl-ais
endef

define Package/rtl-ais/description
  rtl_ais uses a rtl2832u dvb-t dongle to tune AIS (Automatic Identification
  System) used on ships and by vessel traffic services
endef

define Package/rtl-ais/conffiles
/etc/config/rtl_ais
endef

define Package/rtl-ais/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rtl_ais $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/rtl_ais.init $(1)/etc/init.d/rtl_ais
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/uci_rtl_ais $(1)/etc/config/rtl_ais
endef

$(eval $(call BuildPackage,rtl-ais))
