# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=xf86-input-libinput
PKG_VERSION:=0.28.1
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.x.org/releases/individual/driver/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=9ada448e076c0078a84b48e5298fa8ce317565f9b342b74c20429214a707d98b

PKG_BUILD_DEPENDS:=util-macros xorgproto
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xf86-input-libinput
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libinput +xorg-server
  TITLE:=X.Org input driver based on libinput
  URL:=https://xorg.freedesktop.org
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

define Package/xf86-input-libinput/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/xorg/modules/input \
	  $(1)/etc/X11

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/xorg/modules/input/*.so* \
	  $(1)/usr/lib/xorg/modules/input/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share/X11/xorg.conf.d \
	  $(1)/etc/X11/
endef

$(eval $(call BuildPackage,xf86-input-libinput))
