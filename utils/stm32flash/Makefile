#
# Copyright (C) 2012-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=stm32flash
PKG_VERSION:=0.5
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_HASH:=97aa9422ef02e82f7da9039329e21a437decf972cb3919ad817f70ac9a49e306
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_MAINTAINER:=Christian Pointner <equinox@spreadspace.org>
PKG_LICENSE:=GPL-2.0-or-later
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
