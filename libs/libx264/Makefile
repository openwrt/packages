#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=x264
PKG_VERSION:=snapshot-20190324-2245
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://download.videolan.org/x264/snapshots/
PKG_MAINTAINER:=Adrian Panella <ianchi74@outlook.com>
PKG_HASH:=68010057edaadffc7593933d13084e8d32e041c42b17c089513d88c917f2ad54

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS:=$(filter-out -O%,$(TARGET_CFLAGS))
MAKE_FLAGS:=$(filter-out LD=%,$(MAKE_FLAGS)) LD="$(TARGET_CC) -o"

# Instead of blacklisting a boatload of platforms just enable
# optimization where it makes sense (matters) ie ARMv7+ and x86_64

ifneq ($(findstring cortex-a,$(CPU_TYPE)),)
  CONFIGURE_ARGS += --enable-lto
  else
  ifneq ($(CONFIG_TARGET_x86_64),)
    CONFIGURE_ARGS += --enable-lto
    ifeq ($(CONFIG_NASM),y)
      CONFIGURE_VARS+= AS=nasm
      MAKE_FLAGS+= AS=nasm
    endif
    else
    CONFIGURE_VARS+= AS=
    MAKE_FLAGS+= AS=
    CONFIGURE_ARGS += --disable-asm
  endif
endif

CONFIGURE_ARGS += \
		--disable-cli \
		--enable-shared \
		--disable-opencl \
		--enable-pic \
		--disable-avs \
		--disable-ffms \
		--disable-gpac \
		--disable-lsmash

define Package/libx264
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=H264/AVC free codec library
  DEPENDS:=+libpthread @BUILD_PATENTED
  URL:=https://www.videolan.org/developers/x264.html
endef

define Package/libx264/description
  x264 is a free software library for encoding
  video streams into the H.264/MPEG-4 AVC compression format.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/x264/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
endef

define Package/libx264/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libx264))
