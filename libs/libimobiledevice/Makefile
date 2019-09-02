#
# Copyright (C) 2012-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libimobiledevice
PKG_SOURCE_DATE:=2019-02-16
PKG_SOURCE_VERSION:=0584aa90c93ff6ce46927b8d67887cb987ab9545
PKG_RELEASE:=2

PKG_MAINTAINER:=
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING.LESSER

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/libimobiledevice/libimobiledevice/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=286e294aad60ef04a39ce70512a0e816415167c982f3e6c2988d9a6b8c5ee29b
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/libimobiledevice/Default
  TITLE:=A library that talks to Apple devices.
  URL:=https://www.libimobiledevice.org/
endef

define Package/libimobiledevice/Default/description
  libimobiledevice is a software library that talks the protocols to support
  iPhone®, iPod Touch®, iPad® and Apple TV® devices.
endef

define Package/libimobiledevice
  $(call Package/libimobiledevice/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=$(ICONV_DEPENDS) +libplist +libusbmuxd +libopenssl
endef

define Package/libimobiledevice/description
  $(call Package/libimobiledevice/Default/description)
endef

define Package/libimobiledevice-utils
  $(call Package/libimobiledevice/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libimobiledevice
endef

define Package/libimobiledevice-utils/description
  $(call Package/libimobiledevice/Default/description)
  This package contains the libimobiledevice utilities.
endef

CONFIGURE_VARS += ac_cv_sys_file_offset_bits=64
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
