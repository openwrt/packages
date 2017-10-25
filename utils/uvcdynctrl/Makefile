#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=uvcdynctrl
PKG_VERSION:=0.2.4
PKG_REV:=2

PKG_SOURCE:=libwebcam-src-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/libwebcam
PKG_HASH:=91741aca11f079eb6d043e31b7da6fe1f7927c28d7496590386928f8466b4297
PKG_MAINTAINER:=Roger D <rogerdammit@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/libwebcam-src-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/uvcdynctrl
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libwebcam
  TITLE:=Manage dynamic controls in uvcvideo
  URL:=http://sourceforge.net/projects/libwebcam/
  MENU:=1
endef

define Package/uvcdynctrl/description
  The webcam-tools package contains the following two components:
  - libwebcam: Webcam Library (LGPL)
  - uvcdynctrl: Manage dynamic controls in uvcvideo (GPL)
endef

define Package/libwebcam
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libxml2 +libiconv-full
  TITLE:=Webcam library
  URL:=http://sourceforge.net/projects/libwebcam/
endef

define Package/libwebcam/description
  $(call Package/uvcdynctrl/description)
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/lib/libiconv-full/include -liconv
TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib/libiconv-full/lib

define Package/uvcdynctrl/install
	$(INSTALL_DIR) $(1)/usr/{bin,share}
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/uvcdynctrl* $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/uvcdynctrl/ $(1)/usr/share/
endef

define Package/libwebcam/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwebcam.so* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{include,lib}
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwebcam.{a,so*} $(1)/usr/lib/
endef

$(eval $(call BuildPackage,uvcdynctrl))
$(eval $(call BuildPackage,libwebcam))
