#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libsamplerate
PKG_VERSION:=0.2.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/libsndfile/libsamplerate/releases/download/$(PKG_VERSION)
PKG_HASH:=3258da280511d24b49d6b08615bbe824d0cacc9842b0e4caf11c52cf2b043893

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:libsamplerate_project:libsamplerate

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libsamplerate
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libsndfile
  TITLE:=Sample Rate Converter
  URL:=https://libsndfile.github.io/libsamplerate/
endef

define Package/libsamplerate/description
 Secret Rabbit Code (aka libsamplerate) is a Sample Rate
 Converter for audio.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--disable-fftw \

define Build/InstallDev
	$(INSTALL_DIR) $(1)
	$(CP) $(PKG_INSTALL_DIR)/* $(1)/
endef

define Package/libsamplerate/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsamplerate.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libsamplerate))
