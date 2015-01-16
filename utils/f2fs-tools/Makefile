#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=f2fs-tools
PKG_VERSION:=1.4.0
PKG_RELEASE:=1

PKG_LICENSE:=GPLv2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://git.kernel.org/cgit/linux/kernel/git/jaegeuk/f2fs-tools.git/snapshot/
PKG_MD5SUM:=be9bfdddf3e5fd5e701a88d0b388dc26

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_MAINTAINER:=Luka Perkov <luka@openwrt.org>

include $(INCLUDE_DIR)/package.mk

define Package/f2fs-tools
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Filesystem
  TITLE:=Tools for Flash-Friendly File System (F2FS)
  DEPENDS:=+libuuid +libf2fs
  URL:=http://git.kernel.org/cgit/linux/kernel/git/jaegeuk/f2fs-tools.git
  MENU:=1
endef

define Package/libf2fs
  $(call Package/lxc/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for Flash-Friendly File System (F2FS) tools
  DEPENDS:=
endef

define Package/f2fs-tools/config
  source "$(SOURCE)/Config.in"
endef

define Package/libf2fs/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libf2fs.so* $(1)/usr/lib/
endef

define Package/f2fs-tools/install
	$(INSTALL_DIR) $(1)/usr/sbin

ifeq ($(CONFIG_F2FS_UTILS_f2fstat),y)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/sbin/f2fstat $(1)/usr/sbin
endif

ifeq ($(CONFIG_F2FS_UTILS_fibmap_f2fs),y)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/sbin/fibmap.f2fs $(1)/usr/sbin
endif

ifeq ($(CONFIG_F2FS_UTILS_fsck_f2fs),y)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/sbin/fsck.f2fs $(1)/usr/sbin
endif

ifeq ($(CONFIG_F2FS_UTILS_dump_f2fs),y)
	ln -s /usr/sbin/fsck.f2fs $(1)/usr/sbin/dump.f2fs
endif

ifeq ($(CONFIG_F2FS_UTILS_mkfs_f2fs),y)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/sbin/mkfs.f2fs $(1)/usr/sbin
endif

endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libf2fs.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libf2fs.a $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libf2fs))
$(eval $(call BuildPackage,f2fs-tools))
