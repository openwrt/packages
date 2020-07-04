#
# Copyright (C) 2019 Valentín Kivachuk <vk18496@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=leptonica
PKG_VERSION:=1.78.0
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.leptonica.org/source/
PKG_HASH:=e2ed2e81e7a22ddf45d2c05f0bc8b9ae7450545d995bfe28517ba408d14a5a88

PKG_MAINTAINER:=Valentín Kivachuk <vk18496@gmail.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=leptonica-license.txt

PKG_BUILD_PARALLEL:=1
CMAKE_BINARY_SUBDIR:=openwrt-build

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libleptonica
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A library for efficient image processing and image analysis operations
  URL:=http://www.leptonica.org/
  DEPENDS:=+giflib +libjpeg +libpng +libtiff +libwebp +zlib
endef

TARGET_CFLAGS:=$(filter-out -O%,$(TARGET_CFLAGS)) -O3

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/leptonica
	$(CP) $(PKG_INSTALL_DIR)/usr/include/leptonica/*.h $(1)/usr/include/leptonica/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libleptonica.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/cmake
	$(CP) $(PKG_INSTALL_DIR)/usr/cmake/*.cmake $(1)/usr/lib/cmake/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/lept.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libleptonica/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libleptonica.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libleptonica))
