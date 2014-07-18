#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmad
PKG_VERSION:=0.15.1b
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/mad \
	ftp://ftp.mars.org/pub/mpeg/
PKG_MD5SUM:=1be543bc30c56fb6bea1d7bf6a64e66c
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

FPM:=default
ifeq ($(ARCH),armeb)
  FPM:=arm
endif
ifeq ($(ARCH),i386)
  FPM:=intel
endif
ifeq ($(ARCH),mipsel)
  FPM:=mips
endif

define Package/libmad
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=An high-quality MPEG audio decoding library
  URL:=http://www.underbit.com/products/mad/
  DEPENDS:=@BUILD_PATENTED
endef

define Package/libmad/description
	MAD is a high-quality MPEG audio decoder. It currently supports
	MPEG-1 and the MPEG-2 extension to lower sampling frequencies,
	as well as the de facto MPEG 2.5 format. All three audio layers -
	Layer I, Layer II, and Layer III (i.e. MP3) - are fully implemented.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS+= \
	--enable-shared \
	--enable-static \
	--enable-fpm="$(FPM)" \
	--disable-debugging \
	--enable-speed \

MAKE_FLAGS+= \
	CFLAGS="$(TARGET_CFLAGS)" \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/mad.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmad.{a,so*} $(1)/usr/lib/
endef

define Package/libmad/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmad.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libmad))
