#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hidapi
PKG_VERSION:=0.15.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/libusb/hidapi
PKG_SOURCE_VERSION:=hidapi-$(PKG_VERSION)
PKG_MIRROR_HASH:=7c82b8c72184726fd4cb9a23390881a4827d4cbac6ee314501efdd41ad08b7b8

PKG_MAINTAINER:=Paul Fertser <fercerpav@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE-bsd.txt

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/hidapi
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libusb-1.0 +libudev $(ICONV_DEPENDS)
  TITLE:=Library to talk to HID devices
  URL:=https://github.com/libusb/hidapi
endef

define Package/hidapi/description
HIDAPI is a multi-platform library which allows an application to interface
with USB and Bluetooth HID-Class devices on Windows, Linux, FreeBSD, and Mac
OS X.  HIDAPI can be either built as a shared library (.so or .dll) or
can be embedded directly into a target application by adding a single source
file (per platform) and a single header.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/hidapi
	$(CP) $(PKG_INSTALL_DIR)/usr/include/hidapi/hidapi.h $(1)/usr/include/hidapi/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/hidapi/hidapi_libusb.h $(1)/usr/include/hidapi/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhidapi-hidraw.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhidapi-libusb.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/hidapi-libusb.pc $(1)/usr/lib/pkgconfig/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/hidapi-hidraw.pc $(1)/usr/lib/pkgconfig/
endef

define Package/hidapi/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhidapi-hidraw.so.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhidapi-libusb.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,hidapi))
