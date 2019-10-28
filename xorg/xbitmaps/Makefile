# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=xbitmaps
PKG_VERSION:=1.1.2
PKG_RELEASE:=1

PKG_SOURCE_URL:= https://www.x.org/pub/individual/data/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=b9f0c71563125937776c8f1f25174ae9685314cbd130fb4c2efce811981e07ee

PKG_BUILD_DEPENDS:=util-macros
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xbitmaps
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=
  TITLE:=contains bitmap images used by applications built in Xorg
  URL:=http://xorg.freedesktop.org/
endef

CONFIGURE_ARGS += \
  --prefix=/usr

define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/include \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/include/X11 \
	  $(1)/usr/include/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share/pkgconfig \
	  $(1)/usr/lib/
endef

define Package/xbitmaps/install
	$(INSTALL_DIR) \
	  $(1)/usr/include/X11

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/include/X11/bitmaps \
	  $(1)/usr/include/X11/
endef

$(eval $(call BuildPackage,xbitmaps))
