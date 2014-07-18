#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=flac
PKG_VERSION:=1.2.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/flac
PKG_MD5SUM:=
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_INSTALL:=1

PKG_LICENSE:=GFDLv1.2 GPLv2 LGPLv2.1 BSD-3c
PKG_LICENSE_FILES:=README COPYING.FDL COPYING.GPL COPYING.LGPL COPYING.Xiph

PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=autogen.sh aclocal.m4

include $(INCLUDE_DIR)/package.mk

define Package/libflac
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Free Lossless Audio Codec library
  URL:=http://flac.sourceforge.net/
endef

define Build/Configure
	$(call Build/Configure/Default, \
		--disable-cpplibs \
		--disable-sse \
		--disable-3dnow \
		--disable-altivec \
		--disable-doxgen-docs \
		--disable-local-xmms-plugin \
		--disable-xmms-plugin \
		--disable-ogg \
		--disable-oggtest \
		--disable-debug \
	)
endef

TARGET_CFLAGS += $(FPIC)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/FLAC \
		$(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libFLAC.{a,so*,la} \
		$(1)/usr/lib/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* \
		$(1)/usr/lib/pkgconfig/

	$(INSTALL_DIR) $(1)/usr/share/aclocal/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/share/aclocal/* \
		$(1)/usr/share/aclocal/
endef

define Package/libflac/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libFLAC.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libflac))
