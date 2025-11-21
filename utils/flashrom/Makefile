#
# Copyright (C) 2010-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=flashrom
PKG_VERSION:=1.3.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://download.flashrom.org/releases
PKG_HASH:=a053234453ccd012e79f3443bdcc61625cf97b7fd7cb4cdd8bfbffbe8b149623
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-v$(PKG_VERSION)

PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk
include flashrom.mk

define Package/flashrom/default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=FlashROM Utility
  URL:=https://www.flashrom.org/
endef

define Package/flashrom
  $(Package/flashrom/default)
  TITLE+= (full)
  DEPENDS+= \
    +(TARGET_x86||TARGET_x86_64):dmidecode \
    +libftdi1 \
    +libusb-1.0 \
    +pciutils
  VARIANT:=full
  DEFAULT_VARIANT:=1
endef

define Package/flashrom-pci
  $(Package/flashrom/default)
  TITLE+= (pci)
  DEPENDS+= \
    +(TARGET_x86||TARGET_x86_64):dmidecode \
    +pciutils
  VARIANT:=pci
endef

define Package/flashrom-spi
  $(Package/flashrom/default)
  TITLE+= (spi)
  VARIANT:=spi
endef

define Package/flashrom-usb
  $(Package/flashrom/default)
  TITLE+= (usb)
  DEPENDS+= \
    +libftdi1 \
    +libusb-1.0
  VARIANT:=usb
endef

define Package/libflashrom
  $(Package/flashrom/default)
  TITLE+= (library)
  DEPENDS+= \
    +(TARGET_x86||TARGET_x86_64):dmidecode \
    +libftdi1 \
    +libusb-1.0 \
    +pciutils
  VARIANT:=full
endef

define Package/flashrom/default/description
 flashrom is an utility for identifying, reading, writing, verifying
 and erasing flash chips. It's often used to flash BIOS/EFI/coreboot
 /firmware images.
endef
Package/flashrom/description = $(Package/flashrom/default/description)
Package/flashrom-pci/description = $(Package/flashrom/default/description)
Package/flashrom-spi/description = $(Package/flashrom/default/description)
Package/flashrom-usb/description = $(Package/flashrom/default/description)
Package/libflashrom/description = $(Package/flashrom/default/description)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libflashrom.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/flashrom.pc $(1)/usr/lib/pkgconfig/
endef

define Package/flashrom/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/flashrom $(1)/usr/sbin/flashrom
endef
define Package/flashrom-pci/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/flashrom $(1)/usr/sbin/flashrom-pci
endef
define Package/flashrom-spi/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/flashrom $(1)/usr/sbin/flashrom-spi
endef
define Package/flashrom-usb/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/flashrom $(1)/usr/sbin/flashrom-usb
endef
define Package/libflashrom/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libflashrom.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,flashrom))
$(eval $(call BuildPackage,flashrom-pci))
$(eval $(call BuildPackage,flashrom-spi))
$(eval $(call BuildPackage,flashrom-usb))
$(eval $(call BuildPackage,libflashrom))
