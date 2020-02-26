#
# Copyright (C) 2012-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libimobiledevice
PKG_SOURCE_DATE:=2020-02-19
PKG_SOURCE_VERSION:=3d8d13f0a70cefc1b12571b7f6aa2d1d4c58cffb
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/libimobiledevice/libimobiledevice
PKG_MIRROR_HASH:=4239f90c68ecd250a900b5256eafc364c658dcb8cc7767c58bd59b6d6b249d4e

PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING.LESSER

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libimobiledevice/Default
  TITLE:=A library that talks to Apple devices.
  URL:=https://www.libimobiledevice.org/
  SUBMENU:=libimobiledevice
endef

define Package/libimobiledevice/Default/description
  libimobiledevice is a software library that talks the protocols to support
  iPhone®, iPod Touch®, iPad® and Apple TV® devices.
endef

define Package/libimobiledevice
  $(call Package/libimobiledevice/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libplist +libusbmuxd +libopenssl
  LICENSE:=LGPL-2.1-or-later
  LICENSE_FILES:=COPYING.LESSER
endef

define Package/libimobiledevice/description
  $(call Package/libimobiledevice/Default/description)
endef

define Package/libimobiledevice-utils
  $(call Package/libimobiledevice/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libimobiledevice
  LICENSE:=GPL-2.0-or-later
  ICENSE_FILES:=COPYING
endef

define Package/libimobiledevice-utils/description
  $(call Package/libimobiledevice/Default/description)
  This package contains the libimobiledevice utilities.
endef

CONFIGURE_ARGS += --without-cython

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libimobiledevice $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libimobiledevice.{a,la,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libimobiledevice-*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libimobiledevice/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libimobiledevice.so.* $(1)/usr/lib/
endef

define Package/libimobiledevice-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/idevice* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libimobiledevice))
$(eval $(call BuildPackage,libimobiledevice-utils))
