#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=libfuse3
PKG_VERSION:=3.9.1
PKG_RELEASE:=1

PKG_SOURCE:=fuse-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/libfuse/libfuse/releases/download/fuse-$(PKG_VERSION)
PKG_HASH:=1bafcfd6c66ba35b7b0beb822532a9106eb8409ad6cde988888fde85f89be645
PKG_BUILD_DIR:=$(BUILD_DIR)/fuse-$(PKG_VERSION)

PKG_MAINTAINER:=
PKG_CPE_ID:=cpe:/a:fuse_project:fuse

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=meson/host

include $(INCLUDE_DIR)/package.mk
include ../../devel/meson/meson.mk

define Package/libfuse3
  TITLE:=FUSE3 library
  URL:=https://github.com/libfuse/libfuse
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+kmod-fuse +libpthread
  SUBMENU:=Filesystem
  ABI_VERSION:=1
  LICENSE:=LGPL-2.1-only
  LICENSE_FILES:=LGPL2.txt
endef

define Package/libfuse3/description
 fuse3 (Filesystem in UserSpacE)
 This package contains the fuse3 shared libraries, needed by other programs.
 - libfuse3
endef

MESON_ARGS += \
	-Ddisable-mtab=true \
	-Dutils=false \
	-Dexamples=false \
	-Duseroot=false

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/fuse3
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/fuse3/*.h $(1)/usr/include/fuse3
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfuse3.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/fuse3.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libfuse3/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfuse3.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libfuse3))
