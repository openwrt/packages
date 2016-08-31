#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=motion
PKG_VERSION=3.4.0-20141018-$(PKG_SOURCE_VERSION)
PKG_RELEASE:=3

PKG_MAINTAINER:=Roger D <rogerdammit@gmail.com>
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Mr-Dave/motion.git
PKG_SOURCE_VERSION:=9479d910f2149b5558788bb86f97f26522794212

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/motion
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=+libjpeg +libpthread
  TITLE:=webcam motion sensing and logging
  URL:=http://www.lavrsen.dk/twiki/bin/view/Motion/WebHome
endef

define Package/motion/conffiles
/etc/motion.conf
endef

CONFIGURE_ARGS+= \
	--without-optimizecpu \
	--without-ffmpeg \
	--without-jpeg-mmx \
	--without-sdl \
	--without-mysql \
	--without-pgsql \
	--without-sqlite3 \

define Package/motion/install
	$(INSTALL_DIR) $(1)/etc
	$(CP) $(PKG_BUILD_DIR)/motion-dist.conf $(1)/etc/motion.conf
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/motion $(1)/usr/bin/

endef

$(eval $(call BuildPackage,motion))
