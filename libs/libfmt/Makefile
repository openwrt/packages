#
# Copyright (C) 2018 Othmar Truniger
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libfmt
PKG_VERSION:=11.0.1
PKG_RELEASE:=1

PKG_SOURCE_NAME:=fmt
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/fmtlib/$(PKG_SOURCE_NAME)/tar.gz/$(PKG_VERSION)?
PKG_HASH:=7d009f7f89ac84c0a83f79ed602463d092fbf66763766a907c97fd02b100f5e9
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Othmar Truniger <github@truniger.ch>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.rst
PKG_CPE_ID:=cpe:/a:fmt:fmt

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += -DBUILD_SHARED_LIBS=ON
CMAKE_OPTIONS += -DFMT_DOC=OFF
CMAKE_OPTIONS += -DFMT_TEST=OFF

define Package/libfmt
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Small, safe and fast formatting library
  URL:=https://github.com/fmtlib/fmt
  DEPENDS:=+libstdcpp
endef

define Package/libfmt/description
  fmt is an open-source formatting library for C++.
  It can be used as a safe alternative to printf or as a fast alternative to IOStreams.
endef

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/fmt.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/fmt.pc
endef

define Package/libfmt/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfmt.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libfmt))
