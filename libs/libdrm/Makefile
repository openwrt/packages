# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=libdrm
PKG_VERSION:=2.4.70
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://dri.freedesktop.org/libdrm
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=b17d4b39ed97ca0e4cffa0db06ff609e617bac94646ec38e8e0579d530540e7b

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libdrm
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=
  TITLE:=libdrm
  URL:=http://dri.freedesktop.org/
endef

CONFIGURE_ARGS += \
  --disable-udev \
  --enable-kms \
  --disable-intel \
  --disable-radeon \
  --disable-amdgpu \
  --disable-nouveau \
  --disable-vmwgfx \
  --disable-omap-experimental-api \
  --disable-exynos-experimental-api \
  --disable-freedreno \
  --disable-freedreno-kgsl \
  --disable-tegra-experimental-api \
  --disable-vc4 \
  --disable-cairo-tests \
  --disable-manpages \
  --disable-valgrind

define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/include \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/include/* \
	  $(1)/usr/include/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/{pkgconfig,*.so*} \
	  $(1)/usr/lib/
endef

define Package/libdrm/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/*.so* \
	  $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libdrm))
