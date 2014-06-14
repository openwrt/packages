#
# Copyright (C) 2012-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=stm32flash
PKG_REV:=4d7ce45
PKG_VERSION:=git~$(PKG_REV)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=git://gitorious.org/stm32flash/stm32flash.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_PROTO:=git

include $(INCLUDE_DIR)/package.mk

define Package/stm32flash
  SECTION:=utils
  CATEGORY:=Utilities
  MAINTAINER:=Christian Pointner <equinox@spreadspace.org>
  URL:=http://code.google.com/p/stm32flash/
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
