#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libftdi1
PKG_VERSION:=1.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://www.intra2net.com/en/developer/libftdi/download/
PKG_MD5SUM:=b79a6356978aa8e69f8eecc3a720ff79
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

PKG_LICENSE:=LGPL-2.0
PKG_LICENSE_FILES:=COPYING.LIB

PKG_INSTALL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libftdi1
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libusb-1.0
  TITLE:=Library to talk to FTDI chips
  URL:=http://www.intra2net.com/en/developer/libftdi/
endef

define Package/libftdi1/description
  libFTDI - FTDI USB driver with bitbang mode
  libFTDI is an open source library to talk to FTDI chips: FT232BM, FT245BM, FT2232C, FT2232H, FT4232H, FT2232D and FT245R, including the popular bitbang mode. 
  The library is linked with your program in userspace, no kernel driver required.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/libftdi1/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libftdi1/ftdi.h $(1)/usr/include/libftdi1/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libftdi1.{a,so} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libftdi1.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libftdi1.pc $(1)/usr/lib/pkgconfig/libftdi1.pc
endef

define Package/libftdi1/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libftdi1.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libftdi1))
