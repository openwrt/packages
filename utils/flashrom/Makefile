#
# Copyright (C) 2010-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=flashrom
PKG_VERSION:=0.9.8
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://download.flashrom.org/releases
PKG_MD5SUM:=ac513076b63ab7eb411a7694bb8f6fda
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include flashrom.mk

define Package/flashrom
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=FlashROM Utility
  URL:=http://www.flashrom.org/
  DEPENDS:=\
	+(TARGET_x86||TARGET_x86_64):dmidecode \
	+FLASHROM_FTDI:libftdi \
	+FLASHROM_PCI:pciutils \
	+FLASHROM_USB:libusb-compat
endef

define Package/flashrom/config
	source "$(SOURCE)/Config.in"
endef

define Package/flashrom/description
 flashrom is an utility for identifying, reading, writing, verifying
 and erasing flash chips. It's often used to flash BIOS/EFI/coreboot
 /firmware images.
endef

MAKE_FLAGS += \
	PREFIX="/usr"

define Package/flashrom/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/flashrom $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,flashrom))
