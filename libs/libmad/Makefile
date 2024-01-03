#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmad
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=0.16.4
PKG_SOURCE_URL:=https://codeberg.org/tenacityteam/libmad
PKG_MIRROR_HASH:=729c78430c2fa4bf5bb25aa3f25b6a6cd5367e5255057e6211a48f6cde6a953a

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:underbit:mad_libmad

CMAKE_INSTALL:=1
PKG_BUILD_FLAGS:=no-mips16

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libmad
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=An high-quality MPEG audio decoding library
  URL:=http://www.underbit.com/products/mad/
endef

define Package/libmad/description
	MAD is a high-quality MPEG audio decoder. It currently supports
	MPEG-1 and the MPEG-2 extension to lower sampling frequencies,
	as well as the de facto MPEG 2.5 format. All three audio layers -
	Layer I, Layer II, and Layer III (i.e. MP3) - are fully implemented.
endef

CMAKE_OPTIONS += \
	-DOPTIMIZE=SPEED

TARGET_CFLAGS:= $(filter-out -O%,$(TARGET_CFLAGS)) -O2

define Package/libmad/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmad.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libmad))
