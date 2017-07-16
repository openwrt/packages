#
# Copyright (C) 2014-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=opus
PKG_VERSION:=1.2.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://archive.mozilla.org/pub/opus/
PKG_HASH:=cfafd339ccd9c5ef8d6ab15d7e1a412c054bf4cb4ecbbbcc78c12ef2def70732

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Ted Hess <thess@kitchensync.net>, Ian Leonard <antonlacon@gmail.com>

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libopus
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=OPUS Audio Codec
  URL:=http://opus-codec.org/
endef

define Package/libopus/description
 Opus is a totally open, royalty-free, highly versatile audio codec. Opus is
 unmatched for interactive speech and music transmission over the Internet, but
 is also intended for storage and streaming applications.
endef

CONFIGURE_ARGS+= \
	--disable-doc \
	--disable-extra-programs

ifeq ($(CONFIG_SOFT_FLOAT),y)
	CONFIGURE_ARGS+= \
		--enable-fixed-point
endif

ifneq ($(findstring neon,$(CONFIG_TARGET_OPTIMIZATION)),)
	CONFIGURE_ARGS+= \
		--enable-fixed-point
endif

CPU_ASM_BLACKLIST:=xscale arm926ej-s

ifneq ($(findstring $(call qstrip,$(CONFIG_CPU_TYPE)),$(CPU_ASM_BLACKLIST)),)
	CONFIGURE_ARGS+= --disable-asm
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/opus $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopus.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/opus.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libopus/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopus.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libopus))
