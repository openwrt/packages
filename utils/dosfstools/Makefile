#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dosfstools
PKG_VERSION:=4.0
PKG_RELEASE:=1

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING

PKG_MAINTAINER:=David Bonnes <david.bonnes@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/dosfstools/dosfstools/releases/download/v$(PKG_VERSION)/ \
		http://fossies.org/linux/misc
PKG_MD5SUM:=9037738953559d1efe04fc5408b6846216cc0138f7f9d32de80b6ec3c35e7daf

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

CONFIGURE_ARGS += \
	--enable-compat-symlinks \
	--without-udev

define Package/dosfstools/Default
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://github.com/dosfstools
  SUBMENU:=Filesystem
  DEPENDS:=$(ICONV_DEPENDS)
endef

define Package/dosfsck
  $(call Package/dosfstools/Default)
  TITLE:=fsck (fsck.fat) utility from dosfstools
endef

define Package/dosfslabel
  $(call Package/dosfstools/Default)
  TITLE:=fslabel (fatlabel) utility from dosfstools
endef

define Package/mkdosfs
  $(call Package/dosfstools/Default)
  TITLE:=mkfs (mkfs.fat) utility from dosfstools
endef

define Package/dosfsck/description
	Utilities to create and check MS-DOS FAT filesystems.
	(fsck.vfat and fsck.fat for checking integrity of FAT volumes)
endef

define Package/dosfslabel/description
	Utilities to create and check MS-DOS FAT filesystems.
	(fatlabel for reading and writing labels of FAT volumes)
endef

define Package/mkdosfs/description
	Utilities to create and check MS-DOS FAT filesystems.
	(mkfs.vfat and mkfs.fat for creating FAT volumes)
endef

define Package/dosfsck/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/dosfsck $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/fsck.fat $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/fsck.msdos $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/fsck.vfat $(1)/usr/sbin/
endef

define Package/dosfslabel/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/dosfslabel $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/fatlabel $(1)/usr/sbin/
endef

define Package/mkdosfs/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/mkdosfs $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/mkfs.fat $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/mkfs.msdos $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/mkfs.vfat $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,dosfsck))
$(eval $(call BuildPackage,dosfslabel))
$(eval $(call BuildPackage,mkdosfs))
