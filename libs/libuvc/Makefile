#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=libuvc

PKG_VERSION:=0.0.6
PKG_RELEASE:=1
PKG_MAINTAINER:=Roger D <rogerdammit@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ktossell/libuvc/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=42175a53c1c704365fdc782b44233925e40c9344fbb7f942181c1090f06e2873

PKG_LICENSE:=BSD
PKG_LICENSE_FILES:=LICENSE.txt

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libuvc
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=libuvc
	DEPENDS:=+libusb-1.0 +libjpeg
	URL:=https://int80k.com/libuvc
endef

define Package/libuvc/description
 This package contains libuvc is a cross-platform library for USB video devices,
 built atop libusb.
endef

define Package/libuvc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libuvc.so* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{include,lib}
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libuvc.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libuvc))
