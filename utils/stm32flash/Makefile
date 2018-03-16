#
# Copyright (C) 2012-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=stm32flash
PKG_VERSION:=0.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://sourceforge.net/projects/stm32flash/files
PKG_HASH:=023f28b01f644edc235c8815a4352e359d3ebdbe6368aaf6bbc28bab3e6ffa5b
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_MAINTAINER:=Christian Pointner <equinox@spreadspace.org>
PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=gpl-2.0.txt
include $(INCLUDE_DIR)/package.mk

define Package/stm32flash
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Microcontroller programming
  URL:=https://sourceforge.net/projects/stm32flash
  TITLE:=Firmware flash tool for STM32's serial bootloader
endef

define Package/stm32flash/description
  This tool can be used to burn firmware images to STM32 ARM processors
  using the built-in serial bootloader.
endef

define Package/stm32flash/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/stm32flash $(1)/usr/bin/
endef

$(eval $(call BuildPackage,stm32flash))
