# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=libdrm
PKG_VERSION:=2.4.102
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://dri.freedesktop.org/libdrm
PKG_HASH:=8bcbf9336c28e393d76c1f16d7e79e394a7fce8a2e929d52d3ad7ad8525ba05b

PKG_MAINTAINER:=Lucian Cristian <lucian.cristian@gmail.com>
PKG_LICENSE:=BSD-3-Clause

PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=meson/host

include $(INCLUDE_DIR)/package.mk
include ../../devel/meson/meson.mk

define Package/libdrm
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libpciaccess
  TITLE:=libdrm
  URL:=https://dri.freedesktop.org/
endef

define Package/libdrm/description
  LIBDRM is the cross-driver middleware which allows user-space applications
  (such as Mesa and 2D drivers) to communicate with the Kernel by the means
  of the DRI protocol.
endef

MESON_ARGS += \
	-Dlibkms=false \
	-Dintel=false \
	-Dradeon=false \
	-Damdgpu=false \
	-Dnouveau=false \
	-Dvmwgfx=false \
	-Domap=false \
	-Dexynos=false \
	-Dfreedreno=false \
	-Dtegra=false \
	-Dvc4=false \
	-Detnaviv=false \
	-Dcairo-tests=false \
	-Dman-pages=false \
	-Dvalgrind=false \
	-Dfreedreno-kgsl=false \
	-Dinstall-test-programs=false \
	-Dudev=false

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdrm.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libdrm.pc $(1)/usr/lib/pkgconfig
endef

define Package/libdrm/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdrm.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libdrm))
