#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libdouble-conversion
PKG_VERSION:=3.1.5
PKG_RELEASE:=2

PKG_SOURCE:=double-conversion-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/google/double-conversion/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=a63ecb93182134ba4293fd5f22d6e08ca417caafa244afaa751cbfddf6415b13

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/double-conversion-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/double-conversion-$(PKG_VERSION)

PKG_MAINTAINER:=
PKG_LICENSE:=BSD-3c
PKG_LICENSE_FILES:=COPYING LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libdouble-conversion
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Efficient binary-decimal and decimal-binary conversion routines for IEEE doubles
  URL:=https://github.com/google/double-conversion
  DEPENDS:=+libstdcpp
endef

define Package/libdouble-conversion/description
  double-conversion provides binary-decimal and decimal-binary routines for IEEE doubles.

  The library consists of efficient conversion routines that have been extracted
  from the V8 JavaScript engine. The code has been refactored and improved so that
  it can be used more easily in other projects.
endef

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_TESTING=OFF

define Package/libdouble-conversion/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libdouble-conversion))
$(eval $(call HostBuild))
