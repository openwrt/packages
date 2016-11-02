#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dfu-programmer
PKG_VERSION:=0.7.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://downloads.sourceforge.net/project/dfu-programmer/dfu-programmer/$(PKG_VERSION)/
PKG_MD5SUM:=98641b0a7cf1cc8c8be3584d5552f6d8

PKG_MAINTAINER:=Stefan Hellermann <stefan@the2masters.de>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/dfu-programmer
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Microcontroller programming
  TITLE:=USB programmer for Atmel microcontrollers
  URL:=http://dfu-programmer.github.io/
  DEPENDS:=+libusb-1.0
endef

define Package/dfu-programmer/description
  dfu-programmer is a Device Firmware Update (DFU) based USB programmer
  for Atmel chips with a USB bootloader.
endef

define Package/dfu-programmer/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/bin/
endef

$(eval $(call BuildPackage,dfu-programmer))
