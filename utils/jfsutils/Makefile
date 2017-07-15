#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=jfsutils
PKG_VERSION:=1.1.15
PKG_MD5SUM:=8809465cd48a202895bc2a12e1923b5d
PKG_RELEASE:=1
PKG_MAINTAINER:=Ingo Fabbri <der_ulmen@yahoo.de>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://jfs.sourceforge.net/project/pub

include $(INCLUDE_DIR)/package.mk

define Package/jfsutils/Default
  URL:=http://jfsutils.sourceforge.net/
  SUBMENU:=Filesystem
endef

define Package/jfsutils
$(call Package/jfsutils/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=JFS filesystem utilities
  DEPENDS:=+libuuid
endef

define Package/jfsutils/description
 IBM's Journaled File System (JFS) for Linux
 This package contains essential JFS filesystem utilities which consists of
 jfs_fsck, jfs_mkfs and jfs_tune.
endef

define Package/jfs-mkfs
$(call Package/jfsutils)
  TITLE:=Utility for creating JFS filesystems
endef

define Package/jfs-fsck
$(call Package/jfsutils)
  TITLE:=Utilities for checking and repairing JFS filesystems
endef

define Package/jfs-tune
$(call Package/jfsutils)
  TITLE:=Utilitiy for tuning JFS filesystems
endef

define Build/Compile
	$(call Build/Compile/Default)
	make -C $(PKG_BUILD_DIR) DESTDIR="$(PKG_INSTALL_DIR)" install
endef

define Package/jfs-mkfs/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/jfs_mkfs $(1)/usr/sbin/
	ln -sf jfs_mkfs $(1)/usr/sbin/mkfs.jfs
endef

define Package/jfs-fsck/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/jfs_fsck $(1)/usr/sbin/
	ln -sf jfs_fsck $(1)/usr/sbin/fsck.jfs
endef

define Package/jfs-tune/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/jfs_tune $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,jfs-mkfs))
$(eval $(call BuildPackage,jfs-fsck))
$(eval $(call BuildPackage,jfs-tune))
