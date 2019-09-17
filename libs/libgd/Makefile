#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libgd
PKG_VERSION:=2.2.5
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/$(PKG_NAME)/$(PKG_NAME)/releases/download/gd-$(PKG_VERSION)/
PKG_HASH:=8c302ccbf467faec732f0741a859eef4ecae22fea2d2ab87467be940842bde51

PKG_MAINTAINER:=Jo-Philipp Wich <jo@mein.io>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:libgd:gd_graphics_library

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libgd
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libjpeg +libpng +libwebp +LIBGD_TIFF:libtiff +LIBGD_FREETYPE:libfreetype
  TITLE:=The GD graphics library
  URL:=https://libgd.github.io/
  MENU:=1
endef

define Package/libgd/description
  GD is an open source code library for the dynamic creation of images by
  programmers. GD creates PNG, JPEG and GIF images, among other formats.
endef

define Package/libgd/config
	if PACKAGE_libgd
		config LIBGD_TIFF
			bool "TIFF image support"
			default n
			help
				Enable TIFF image support through libtiff
	endif
	if PACKAGE_libgd
		config LIBGD_FREETYPE
			bool "Freetype 2.x library support"
			default n
			help
				Enable Freetype 2.x font engine support through libfreetype
	endif
endef

TARGET_CFLAGS += $(FPIC) -ffunction-sections -fdata-sections -flto

CMAKE_OPTIONS += \
	-DENABLE_FONTCONFIG=OFF \
	-DENABLE_ICONV=OFF \
	-DENABLE_JPEG=ON \
	-DENABLE_LIQ=OFF \
	-DENABLE_PNG=ON \
	-DENABLE_WEBP=ON \
	-DENABLE_XPM=OFF \
	-DZLIB_INCLUDE_DIR="$(STAGING_DIR)/usr"

ifdef CONFIG_LIBGD_TIFF
	CMAKE_OPTIONS += \
		-DENABLE_TIFF=ON
else
	CMAKE_OPTIONS += \
		-DENABLE_TIFF=OFF
endif

ifdef CONFIG_LIBGD_FREETYPE
	CMAKE_OPTIONS += \
		-DENABLE_FREETYPE=ON
else
	CMAKE_OPTIONS += \
		-DENABLE_FREETYPE=OFF
endif

define Package/libgd/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgd.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libgd))
