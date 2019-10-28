# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=xf86-video-ati
PKG_VERSION:=18.1.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.x.org/releases/individual/driver/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=6c335f423c1dc3d904550d41cb871ca4130ba7037dda67d82e3f1555e1bfb9ac

PKG_BUILD_DEPENDS:=util-macros xorgproto
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xf86-video-ati
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libxi +xorg-server
  TITLE:=ATI video driver
  URL:=https://www.x.org
endef

LDFLAGS:="$LDFLAGS -Wl,-z,lazy"

CONFIGURE_ARGS += \
  --prefix=/usr \
  --enable-glamor

#define Build/InstallDev
#	$(INSTALL_DIR) \
#	  $(1)/usr/include \
#	  $(1)/usr/lib
#
#	$(CP) \
#	  $(PKG_INSTALL_DIR)/usr/include/* \
#	  $(1)/usr/include/
#
#	$(CP) \
#	  $(PKG_INSTALL_DIR)/usr/lib/{pkgconfig,*.so*} \
#	  $(1)/usr/lib/
#endef

define Package/xf86-video-ati/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/xorg/modules/drivers

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/xorg/modules/drivers/*.so* \
	  $(1)/usr/lib/xorg/modules/drivers/
endef

$(eval $(call BuildPackage,xf86-video-ati))
