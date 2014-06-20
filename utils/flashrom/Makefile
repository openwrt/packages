#
# Copyright (C) 2010-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=flashrom
PKG_VERSION:=0.9.7
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://download.flashrom.org/releases
PKG_MD5SUM:=d239bafa1b46619d851f70f84a5b122a
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/flashrom
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=FlashROM Utility
  URL:=http://www.flashrom.org/
  DEPENDS:=+zlib +pciutils +(TARGET_x86||TARGET_x86_64):dmidecode +libftdi
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
