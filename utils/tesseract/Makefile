# Copyright (C) 2019 Valentin Kivachuk <vk18496@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tesseract
PKG_VERSION:=5.3.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/tesseract-ocr/tesseract/tar.gz/$(PKG_VERSION)?
PKG_HASH:=141afc12b34a14bb691a939b4b122db0d51bd38feda7f41696822bacea7710c7

PKG_MAINTAINER:=Valentin Kivachuk <vk18496@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

CMAKE_BINARY_SUBDIR:=openwrt-build

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/tesseract
  MENU:=1
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Tesseract Open Source OCR Engine
  URL:=https://github.com/tesseract-ocr/tesseract
  DEPENDS:=+libleptonica +libarchive +libpthread +libstdcpp
endef

TARGET_CFLAGS:=$(filter-out -O%,$(TARGET_CFLAGS)) -O3

CMAKE_OPTIONS += \
	-DAUTO_OPTIMIZE=OFF \
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_TRAINING_TOOLS=OFF \
	-DHAVE_NEON=$(if $(or $(findstring aarch64,$(CONFIG_ARCH)),$(findstring neon,$(CONFIG_CPU_TYPE))),TRUE,FALSE) \
	-DDISABLE_CURL=ON

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/tesseract $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtesseract.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/cmake/tesseract
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cmake/tesseract/*.cmake $(1)/usr/lib/cmake/tesseract
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/tesseract.pc $(1)/usr/lib/pkgconfig/
endef

define Package/tesseract/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,tesseract))
