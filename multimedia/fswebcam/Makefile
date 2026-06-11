#
# Copyright (C) 2010-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fswebcam
PKG_VERSION:=20200725
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.sanslogic.co.uk/fswebcam/files
PKG_HASH:=cff0cbd91457133847e40944db3ee0b6f81d06506cef260687bde8348c8a0ce4

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENCE
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/fswebcam
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=fswebcam
  URL:=https://www.sanslogic.co.uk/fswebcam/
  DEPENDS:=+libgd
endef

define Package/fswebcam/description
  fswebcam is a neat and simple webcam app. It captures images from a V4L1/V4L2 compatible
  device or file, averages them to reduce noise and draws a caption using the GD Graphics
  Library which also handles compressing the image to PNG or JPEG. The resulting image
  is saved to a file or sent to stdio where it can be piped to something like ncftpput or scp.
endef

EXTRA_CFLAGS+= $(TARGET_CPPFLAGS)
EXTRA_LDFLAGS+= $(TARGET_LDFLAGS)

define Package/fswebcam/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/fswebcam $(1)/usr/bin/
endef

$(eval $(call BuildPackage,fswebcam))
