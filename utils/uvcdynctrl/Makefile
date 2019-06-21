#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=uvcdynctrl
PKG_VERSION:=0.2.5
PKG_RELEASE:=2

PKG_SOURCE:=libwebcam-src-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/libwebcam
PKG_HASH:=3ca5199c7b8398b655a7c38e3ad4191bb053b1486503287f20d30d141bda9d41
PKG_BUILD_DIR:=$(BUILD_DIR)/libwebcam-$(PKG_VERSION)

PKG_MAINTAINER:=Roger D <rogerdammit@gmail.com>
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/nls.mk

define Package/uvcdynctrl
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libwebcam
  TITLE:=Manage dynamic controls in uvcvideo
  LICENSE:=GPL-3.0-or-later
  LICENSE_FILES:=uvcdynctrl/COPYING
  URL:=https://sourceforge.net/projects/libwebcam/
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
  DEPENDS:=+libxml2 $(ICONV_DEPENDS)
  TITLE:=Webcam library
  LICENSE:=LGPL-3.0-or-later
  LICENSE_FILES:=libwebcam/COPYING.LESSER
  URL:=https://sourceforge.net/projects/libwebcam/
endef

define Package/libwebcam/description
  $(call Package/uvcdynctrl/description)
endef

define Package/uvcdynctrl/install
	$(INSTALL_DIR) $(1)/usr/{bin,share}
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/uvcdynctrl* $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/uvcdynctrl/ $(1)/usr/share/
endef

define Package/libwebcam/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwebcam.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,uvcdynctrl))
$(eval $(call BuildPackage,libwebcam))
