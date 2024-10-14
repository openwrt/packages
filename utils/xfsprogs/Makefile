#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=xfsprogs
PKG_VERSION:=6.10.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@KERNEL/linux/utils/fs/xfs/xfsprogs
PKG_HASH:=6cb839be1a9535f8352441b3f6eea521ead5c5c7c913e8106cdfac96aa117041

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSES/GPL-2.0
PKG_CPE_ID:=cpe:/a:sgi:xfsprogs

PKG_BUILD_DEPENDS:=inih attr
PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xfsprogs/default
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Filesystem
  DEPENDS:=+liburcu +libuuid +libpthread +libblkid
  URL:=https://xfs.wiki.kernel.org/
endef

define Package/xfs-admin
$(call Package/xfsprogs/default)
  TITLE:=Utilities for changing parameters of an XFS filesystems
endef

define Package/xfs-mkfs
$(call Package/xfsprogs/default)
  TITLE:=Utility for creating XFS filesystems
  DEPENDS+=+libinih
endef

define Package/xfs-fsck
$(call Package/xfsprogs/default)
  TITLE:=Utilities for checking and repairing XFS filesystems
endef

define Package/xfs-growfs
$(call Package/xfsprogs/default)
  TITLE:=Utility for increasing the size of XFS filesystems
endef

CONFIGURE_ARGS += \
	--enable-lto \
	--disable-gettext \
	--disable-lib64 \
	--disable-librt \
	--disable-scrub \
	--disable-libicu

CONFIGURE_VARS += \
	DEBUG=-DNDEBUG \
	OPTIMIZER="$(TARGET_OPTIMIZATION)"

TARGET_CFLAGS += -DHAVE_MAP_SYNC $(if $(CONFIG_USE_MUSL),-D_LARGEFILE64_SOURCE)
TARGET_LDFLAGS += $(if $(CONFIG_USE_GLIBC),-lrt)

define Package/xfs-admin/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/xfs_db $(1)/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/xfs_admin $(1)/sbin
endef

define Package/xfs-mkfs/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/mkfs.xfs $(1)/usr/sbin
endef

define Package/xfs-fsck/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/xfs_repair $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/xfs_db $(1)/usr/sbin
endef

define Package/xfs-growfs/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/xfs_growfs $(1)/usr/sbin
endef

$(eval $(call BuildPackage,xfs-admin))
$(eval $(call BuildPackage,xfs-mkfs))
$(eval $(call BuildPackage,xfs-fsck))
$(eval $(call BuildPackage,xfs-growfs))
