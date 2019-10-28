# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=xorgxrdp
PKG_VERSION:=0.2.9
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/neutrinolabs/xorgxrdp/releases/download/v$(PKG_VERSION)/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=2f24f468771c874d6cda86e09edcf5bd48e88894de9c4ebd2bef9cb6f255c688

PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=xrdp
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xorgxrdp
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+xorg-server
  TITLE:=Xorg drivers for xrdp
  URL:=https://github.com/neutrinolabs/xorgxrdp
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

define Package/xorgxrdp/install
	$(INSTALL_DIR) \
	  $(1)/etc/X11/xrdp \
	  $(1)/usr/lib/xorg/modules/{drivers,input}

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/xorg/modules/drivers/*.so* \
	  $(1)/usr/lib/xorg/modules/drivers/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/xorg/modules/input/*.so* \
	  $(1)/usr/lib/xorg/modules/input/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/xorg/modules/*.so* \
	  $(1)/usr/lib/xorg/modules/
	$(CP) \
	  $(PKG_INSTALL_DIR)/etc/X11/xrdp \
	  $(1)/etc/X11/
endef

$(eval $(call BuildPackage,xorgxrdp))
