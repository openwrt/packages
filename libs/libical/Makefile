#
# Copyright (C) 2009-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libical
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=7c39b3448e4927a2de2775d853f52b3aaeb42400970a3db0b01a78987e6ec0b7
PKG_SOURCE_URL:=@SF/freeassociation

PKG_LICENSE:=LGPL-2.1 MPL-1.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_FIXUP:=libtool
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libical
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=iCal (RFC 2445) library
  URL:=http://www.nabber.org/projects/ical/
  DEPENDS:=+libpthread
endef

define Package/libical/description
 This package provides a a read/write library of classes for object oriented
 languages (Initial goals of PHP and Python) that implement and enforce the iCal
 standard (RFC 2445).
endef

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--disable-cxx \
	--disable-java \
	--disable-python \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/{ical.h,libical} $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libical{,ss,vcal}.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libical.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libical/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libical{,ss,vcal}.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libical))
