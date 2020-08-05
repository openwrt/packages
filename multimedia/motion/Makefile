#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=motion
PKG_VERSION:=4.3.1
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-release-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Motion-Project/motion/tar.gz/release-$(PKG_VERSION)?
PKG_HASH:=545712b10fc4a0134e994b7d8a3773c1c22f0bf4bd7afea7d7ffff357aca9ea5
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-release-$(PKG_VERSION)

PKG_MAINTAINER:=Roger D <rogerdammit@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:lavrsen:motion

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/motion
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=+libjpeg +libpthread +libmicrohttpd $(INTL_DEPENDS) +TARGET_bcm27xx:bcm27xx-userland
  TITLE:=webcam motion sensing and logging
  URL:=https://motion-project.github.io/
endef

define Package/motion/conffiles
/etc/config/motion
/etc/motion.conf
endef

CONFIGURE_ARGS += \
	--without-bktr \
	--without-webp \
	--with$(if $(CONFIG_TARGET_bcm27xx),,out)-mmal \
	--without-ffmpeg \
	--without-mariadb \
	--without-mysql \
	--without-pgsql \
	--without-sqlite3 \
	--without-optimizecpu

define Package/motion/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_CONF) ./files/motion.conf $(1)/etc/config/motion
	$(INSTALL_BIN) ./files/motion.init $(1)/etc/init.d/motion
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/motion/motion-dist.conf $(1)/etc/motion.conf
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/motion $(1)/usr/bin/
endef

$(eval $(call BuildPackage,motion))
