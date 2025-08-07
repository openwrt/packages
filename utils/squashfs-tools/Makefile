#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=squashfs-tools
PKG_VERSION:=4.7
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_CPE_ID:=cpe:/a:squashfs-tools_project:squashfs-tools

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/plougher/squashfs-tools/tar.gz/${PKG_VERSION}?
PKG_HASH:=f1605ef720aa0b23939a49ef4491f6e734333ccc4bda4324d330da647e105328

PKG_BUILD_PARALLEL:=1
include $(INCLUDE_DIR)/package.mk

define Package/squashfs-tools/Default
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Filesystem
  TITLE:=Tools to create and extract Squashfs filesystems
  URL:=https://github.com/plougher/squashfs-tools
  DEPENDS += +libpthread \
	+SQUASHFS_TOOLS_GZIP_SUPPORT:zlib \
	+SQUASHFS_TOOLS_LZO_SUPPORT:liblzo \
	+SQUASHFS_TOOLS_LZ4_SUPPORT:liblz4 \
	+SQUASHFS_TOOLS_XZ_SUPPORT:liblzma \
	+SQUASHFS_TOOLS_ZSTD_SUPPORT:libzstd
endef

define Package/squashfs-tools-mksquashfs
  $(call Package/squashfs-tools/Default)
  TITLE+= mksquashfs
endef

define Package/squashfs-tools-unsquashfs
  $(call Package/squashfs-tools/Default)
  TITLE+= unsquashfs
endef

define Package/squashfs-tools-unsquashfs/config
	source "$(SOURCE)/Config.in"
endef

Build/Configure:=

MAKE_FLAGS += \
	CONFIG=1 \
	SMALL_READER_THREADS=4 \
	BLOCK_READER_THREADS=4 \
	GZIP_SUPPORT=$(if $(CONFIG_SQUASHFS_TOOLS_GZIP_SUPPORT),1,0) \
	XZ_SUPPORT=$(if $(CONFIG_SQUASHFS_TOOLS_XZ_SUPPORT),1,0) \
	XZ_EXTENDED_OPTIONS=$(if $(CONFIG_SQUASHFS_TOOLS_XZ_EXTENDED_SUPPORT),1,0) \
	LZO_SUPPORT=$(if $(CONFIG_SQUASHFS_TOOLS_LZO_SUPPORT),1,0) \
	LZ4_SUPPORT=$(if $(CONFIG_SQUASHFS_TOOLS_LZ4_SUPPORT),1,0) \
	ZSTD_SUPPORT=$(if $(CONFIG_SQUASHFS_TOOLS_ZSTD_SUPPORT),1,0) \

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/squashfs-tools \
		CC="$(TARGET_CC)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
		EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE_FLAGS) \
		mksquashfs unsquashfs
endef

define Package/squashfs-tools-mksquashfs/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/squashfs-tools/mksquashfs $(1)/usr/sbin/mksquashfs
	$(LN) mksquashfs $(1)/usr/sbin/sqfstar
endef

define Package/squashfs-tools-unsquashfs/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/squashfs-tools/unsquashfs $(1)/usr/sbin/unsquashfs
	$(LN) unsquashfs $(1)/usr/sbin/sqfscat
endef

$(eval $(call BuildPackage,squashfs-tools-mksquashfs))
$(eval $(call BuildPackage,squashfs-tools-unsquashfs))
