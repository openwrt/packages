#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hfsprogs
PKG_VERSION:=332.25
PKG_RELEASE:=1

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING

PKG_MAINTAINER:=Florian Fainelli <florian@openwrt.org>

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).orig.tar.gz
PKG_SOURCE_URL:=http://archive.ubuntu.com/ubuntu/pool/universe/h/$(PKG_NAME)
PKG_BUILD_DIR:=$(BUILD_DIR)/diskdev_cmds-$(PKG_VERSION)
PKG_MD5SUM:=261c3de5ec0dcf5244e3f60d79c1d6f1
PKG_LICENSE:=APSL 2.0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

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

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		-f Makefile.lnx \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS+="$(TARGET_CFLAGS) -I$(PKG_BUILD_DIR)/include -DDEBUG_BUILD=0 -D_FILE_OFFSET_BITS=64 -D LINUX=1 -D BSD=1" \
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
