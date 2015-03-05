#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=x264
PKG_VERSION:=snapshot-20141218-2245
PKG_RELEASE:=1

PKG_SOURCE:=${PKG_NAME}-${PKG_VERSION}.tar.bz2
PKG_SOURCE_URL:=http://ftp.videolan.org/videolan/x264/snapshots/
PKG_MD5SUM:=a274a75b3ce350c202d923c8fcab425f
PKG_MAINTAINER:=Luka Perkov <luka@openwrt.org>

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/x264
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=An high-quality MPEG audio decoding library
  URL:=http://www.videolan.org/developers/x264.html
  # DEPENDS:=@BUILD_PATENTED
endef

define Package/x264/description
 x264 is a free software library and application for encoding video streams
 into the H.264/MPEG-4 AVC compression format, and is released under the terms
 of the GNU GPL.
endef

# TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS+= \
	--cross-prefix=${TARGET_CROSS} \
	--sysroot=${STAGING_DIR} \
	--enable-shared \
	--disable-lavf \
	--disable-swscale \
	--enable-pic \
	--disable-asm \

define Build/InstallDev
	# $(INSTALL_DIR) $(1)/usr/include
	# $(CP) $(PKG_INSTALL_DIR)/usr/include/mad.h $(1)/usr/include/
	# $(INSTALL_DIR) $(1)/usr/lib
	# $(CP) $(PKG_INSTALL_DIR)/usr/lib/x264.{a,so*} $(1)/usr/lib/
endef

define Package/x264/install
	# $(INSTALL_DIR) $(1)/usr/lib
	# $(CP) $(PKG_INSTALL_DIR)/usr/lib/x264.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,x264))
