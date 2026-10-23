#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=usbutils
PKG_VERSION:=020
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@KERNEL/linux/utils/usb/usbutils
PKG_HASH:=20287d68fcd9ebb50a05ba0645a4af7583bd8dfc7307215ba121e4bc6d057aa1

PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSES/GPL-2.0-only.txt

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/usbutils
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libusb-1.0 +libudev +usbids
  TITLE:=USB devices listing utilities
  URL:=http://www.linux-usb.org/
  ALTERNATIVES:=200:/usr/bin/lsusb:/usr/libexec/lsusb-usbutils
endef

define Package/usbutils/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/lsusb $(1)/usr/libexec/lsusb-usbutils
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt-build/usbreset $(1)/usr/bin/
endef

$(eval $(call BuildPackage,usbutils))
