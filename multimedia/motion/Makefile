#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=motion
PKG_VERSION:=4.5.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-release-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Motion-Project/motion/tar.gz/release-$(PKG_VERSION)?
PKG_HASH:=42320a1c7b54a3f0b5a49cecf34a5d752760b28383bc573b3ca1240581786fe5
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-release-$(PKG_VERSION)

PKG_MAINTAINER:=Roger D <rogerdammit@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:motion_project:motion

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=gettext-full/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/motion/Default
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=+libjpeg +libpthread +libmicrohttpd $(INTL_DEPENDS)
  TITLE:=webcam motion sensing and logging
  PROVIDES:=motion
  URL:=https://motion-project.github.io/
endef

define Package/motion/Default/description
Motion is a program that monitor video signals from many types of cameras and
depending upon how they are configured, perform actions when movement is
detected.
endef

define Package/motion-noffmpeg
$(call Package/motion/Default)
  TITLE+= (w/o FFMPEG support)
  VARIANT:=noffmpeg
  DEFAULT_VARIANT:=1
endef

define Package/motion-noffmpeg/description
$(call Package/motion/Default/description)
This package is built without FFMPEG support.
endef

define Package/motion-ffmpeg
$(call Package/motion/Default)
  TITLE+= (with FFMPEG support)
  VARIANT:=ffmpeg
  DEPENDS+=+libffmpeg-full
endef

define Package/motion-ffmpeg/description
$(call Package/motion/Default/description)
This package is built with FFMPEG support.
endef

define Package/motion/conffiles
/etc/config/motion
/etc/motion.conf
endef

Package/motion-noffmpeg/conffiles = $(Package/motion/conffiles)
Package/motion-ffmpeg/conffiles = $(Package/motion/conffiles)

CONFIGURE_ARGS += \
	--without-bktr \
	--without-webp \
	--without-mmal \
	--without-mariadb \
	--without-mysql \
	--without-pgsql \
	--without-sqlite3 \
	--without-optimizecpu

ifeq ($(BUILD_VARIANT),noffmpeg)
	CONFIGURE_ARGS += --without-ffmpeg
endif
ifeq ($(BUILD_VARIANT),ffmpeg)
	CONFIGURE_ARGS += --with-ffmpeg
endif

define Package/motion/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_CONF) ./files/motion.conf $(1)/etc/config/motion
	$(INSTALL_BIN) ./files/motion.init $(1)/etc/init.d/motion
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/motion/motion-dist.conf $(1)/etc/motion.conf
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/motion $(1)/usr/bin/
endef
Package/motion-noffmpeg/install = $(Package/motion/install)
Package/motion-ffmpeg/install = $(Package/motion/install)

$(eval $(call BuildPackage,motion-noffmpeg))
$(eval $(call BuildPackage,motion-ffmpeg))
