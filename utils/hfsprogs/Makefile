#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hfsprogs
PKG_REAL_VERSION:=540.1.linux3
PKG_VERSION:=$(subst linux,,$(PKG_REAL_VERSION))
PKG_RELEASE:=2

PKG_SOURCE:=diskdev_cmds-$(PKG_REAL_VERSION).tar.gz
PKG_SOURCE_URL:=https://src.fedoraproject.org/repo/pkgs/hfsplus-tools/$(PKG_SOURCE)/0435afc389b919027b69616ad1b05709
PKG_HASH:=b01b203a97f9a3bf36a027c13ddfc59292730552e62722d690d33bd5c24f5497
PKG_BUILD_DIR:=$(BUILD_DIR)/diskdev_cmds-$(PKG_REAL_VERSION)

PKG_MAINTAINER:=
PKG_LICENSE:=APSL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=util-linux

include $(INCLUDE_DIR)/package.mk

define Package/hfsprogs/Default
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Filesystem
  DEPENDS:=+libopenssl
endef

define Package/hfsfsck
  $(call Package/hfsprogs/Default)
  TITLE:=fsck (fsck.hfs) utility from hfsprogs
endef

define Package/mkhfs
  $(call Package/hfsprogs/Default)
  TITLE:=mkfs (mkfs.hfs) utility from hfsprogs
endef

define Package/hfsfsck/description
	Utilities to create and check HFS/HFS+ filesystems.
	(fsck.hfs and fsck.hfsplus for checking integrity of HFS/HFS+ volumes)
endef

define Package/mkhfs/description
	Utilities to create and check HFS/HFS+ filesystems.
	(mkfs.hfs and mkfs.hfsplus for creating HFS/HFS+ volumes)
endef

define Build/Configure
endef

TARGET_CFLAGS+=$(if $(CONFIG_USE_MUSL),-D__P\(x\)=x -D__va_copy=va_copy -DBSD_SOURCE)

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS+="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS) -I$(PKG_BUILD_DIR)/include -DDEBUG_BUILD=0 -D_FILE_OFFSET_BITS=64 -D LINUX=1 -D BSD=1 -D VERSION=\\\"$(PKG_REAL_VERSION)\\\"" \
		LDFLAGS+="$(TARGET_LDFLAGS)" \
		all
endef

define Package/hfsfsck/install
	$(INSTALL_DIR) $(1)/lib/functions/fsck
	$(INSTALL_DATA) ./files/hfsfsck.sh $(1)/lib/functions/fsck/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/fsck_hfs.tproj/fsck_hfs	$(1)/usr/sbin/fsck.hfsplus
	(cd $(1)/usr/sbin; ln -sf fsck.hfsplus fsck.hfs;)
endef

define Package/mkhfs/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/newfs_hfs.tproj/newfs_hfs $(1)/usr/sbin/mkfs.hfsplus
	(cd $(1)/usr/sbin; ln -sf mkfs.hfsplus mkfs.hfs;)
endef

$(eval $(call BuildPackage,hfsfsck))
$(eval $(call BuildPackage,mkhfs))
