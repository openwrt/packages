#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qrencode
PKG_VERSION:=3.4.4
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://fukuchi.org/works/qrencode/
PKG_MD5SUM:=be545f3ce36ea8fbb58612d72c4222de
PKG_MAINTAINER:=Jonathan Bennett <JBennett@incomsystems.biz>
PKG_LICENSE:=LGPL-2.1+
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/libqrencode
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for encoding data in a QR Code symbol
  URL:=http://fukuchi.org/works/qrencode/
endef

define Package/libqrencode/description
Libqrencode is a C library for encoding data in a QR Code symbol,
a kind of 2D symbology that can be scanned by handy terminals such
as a mobile phone with CCD. The capacity of QR Code is up to 7000
digits or 4000 characters, and is highly robust.
endef

define Package/qrencode
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=qrencode binary for producing qr codes
  URL:=http://fukuchi.org/works/qrencode/
  DEPENDS:=+libqrencode
endef

define Package/qrencode/description
Qrencode is a C program for encoding data in a QR Code symbol,
a kind of 2D symbology that can be scanned by handy terminals such
as a mobile phone with CCD. The capacity of QR Code is up to 7000
digits or 4000 characters, and is highly robust.
endef


CONFIGURE_ARGS+= \
	--enable-shared \
	--enable-static \
	--disable-rpath \
	--disable-sdltest \
	--without-tests 

TARGET_LDFLAGS+= -s

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/qrencode.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libqrencode.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libqrencode.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libqrencode/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libqrencode.so* $(1)/usr/lib/
endef

define Package/qrencode/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/qrencode $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libqrencode))
$(eval $(call BuildPackage,qrencode))
