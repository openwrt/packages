#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dosfstools
PKG_VERSION:=4.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/dosfstools/dosfstools/releases/download/v$(PKG_VERSION)/ \
		http://fossies.org/linux/misc
PKG_HASH:=e6b2aca70ccc3fe3687365009dd94a2e18e82b688ed4e260e04b7412471cc173
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

CONFIGURE_ARGS += \
	--without-udev

define Package/dosfstools
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Filesystem
  DEPENDS:=$(ICONV_DEPENDS)
  TITLE:=Utilities for making and checking MS-DOS FAT filesystems
  URL:=https://github.com/dosfstools
endef

define Package/dosfstools/description
	The dosfstools package includes the mkfs.fat and fsck.fat utilities, which respectively make and check MS-DOS FAT filesystems.
endef

define Package/dosfstools/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/fatlabel $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/fsck.fat $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/mkfs.fat $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,dosfstools))
