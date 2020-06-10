#
# Copyright © 2020 David Woodhouse <dwmw2@infradead.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=minizip
PKG_VERSION:=2.9.3
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/nmoinvaz/minizip/archive/
PKG_HASH:=f64b2d228a03673a8ec36a53402e2108437226fd9170d49b7f0c0bca94708b93

PKG_MAINTAINER:=David Woodhouse <dwmw2@infradead.org>
PKG_LICENSE:=Zlib
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

CMAKE_OPTIONS:=-DINSTALL_INC_DIR=/usr/include/minizip -DMZ_BZIP2=OFF -DBUILD_SHARED_LIBS=ON -DMZ_LIBBSD=OFF

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/minizip
  TITLE:=Fork of the popular zip manipulation library found in the zlib distribution
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+zlib
  URL:=https://github.com/nmoinvaz/minizip
endef

define Package/minizip-dev
  SECTION:=devel
  CATEGORY:=Development
  SUBMENU:=Libraries
  DEPENDS:=minizip
  TITLE:=Development files for the minizip library
endef

define Package/minizip/description
  minizip is a zip manipulation library written in C that is supported on Windows, macOS, and Linux
endef

define Package/minizip/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libminizip.so.* $(1)/usr/lib/
endef

TARGET_CXXFLAGS += -flto

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/minizip.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/minizip.pc
endef

$(eval $(call BuildPackage,minizip))
