# 
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=rtl_433
PKG_VERSION:=18.05
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/merbanan/rtl_433/tar.gz/$(PKG_VERSION)?
PKG_HASH:=4710105234e3b71ae839e2d3f2628d6c12879fcda9c849fffe847d4de42a74f3

CMAKE_INSTALL:=1

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/rtl_433
  TITLE:=Realtek RTL2832 based 433.92MHz generic data receiver
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+librtlsdr +rtl-sdr +libtool-bin
  URL:=https://github.com/merbanan/rtl_433
  MAINTAINER:=Jasper Scholte <NightNL@outlook.com>
endef

define Package/rtl-sdr/description
  rtl_433 turns your Realtek RTL2832 based DVB dongle into a 433.92MHz generic data receiver.
endef

define Package/rtl_433/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/rtl_433 $(1)/usr/bin
endef

$(eval $(call BuildPackage,rtl_433))
