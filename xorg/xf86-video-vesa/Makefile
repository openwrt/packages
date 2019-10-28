# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=xf86-video-vesa
PKG_VERSION:=2.4.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.x.org/releases/individual/driver/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=bf443c94d7bf6cd4e248f8a3147f4647be04dc4c80250d9405006263bbdee38c

PKG_BUILD_DEPENDS:=util-macros xorgproto
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xf86-video-vesa
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libxi +xorg-server
  TITLE:=X.org generic VESA video driver
  URL:=https://www.x.org
endef

LDFLAGS:="$LDFLAGS -Wl,-z,lazy"

CONFIGURE_ARGS += \
  --prefix=/usr

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

define Package/xf86-video-vesa/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/xorg/modules/drivers

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/xorg/modules/drivers/*.so* \
	  $(1)/usr/lib/xorg/modules/drivers/
endef

$(eval $(call BuildPackage,xf86-video-vesa))
