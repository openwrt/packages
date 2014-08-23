#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=rtl-sdr
PKG_VERSION:=2014-02-10
PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://git.osmocom.org/rtl-sdr.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=6ee557360645da158e3065111349c318894b497b
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
CMAKE_INSTALL:=1

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

PKG_MAINTAINER:=Vasilis Tsiligiannis <b_tsiligiannis@silverton.gr>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/rtl-sdr/Default
  TITLE:=Software Defined Radio with Realtek RTL2832U
  URL:=http://sdr.osmocom.org/trac/wiki/rtl-sdr
endef

define Package/rtl-sdr/Default/description
  rtl-sdr allows DVB-T dongles based on the Realtek RTL2832U to be used as
  an inexpensive SDR.
endef

define Package/rtl-sdr
  $(call Package/rtl-sdr/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+librt +libpthread +librtlsdr
endef

define Package/rtl-sdr/description
  $(call Package/rtl-sdr/Default/description)

  This package contains the utilities and daemons.
endef

define Package/librtlsdr
  $(call Package/rtl-sdr/Default)
  TITLE+= shared library
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= library
  DEPENDS:=+libusb-1.0
endef

define Package/librtlsdr/description
  $(call Package/rtl-sdr/Default/description)

  This package contains the librtlsdr shared library.
endef

TARGET_CFLAGS += $(FPIC)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/librtlsdr.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/librtlsdr.pc $(1)/usr/lib/pkgconfig/
endef

define Package/rtl-sdr/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/rtl_* $(1)/usr/bin/
endef

define Package/librtlsdr/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/librtlsdr.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,rtl-sdr))
$(eval $(call BuildPackage,librtlsdr))
