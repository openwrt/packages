# 
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=squashfs-tools
PKG_VERSION:=4.3
PKG_RELEASE:=6
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/plougher/squashfs-tools
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=5be5d61e5e5a93911256b5f2106e50da0ca81e8d
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=eac1bc559708dc8656fe7d099ffc9e9374ae0cfb9a12d180a9c0c28acb0adf11

PKG_BUILD_PARALLEL:=1
include $(INCLUDE_DIR)/package.mk

define Package/squashfs-tools/Default
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Filesystem
  TITLE:=squashfs-tools
  URL:=https://github.com/plougher/squashfs-tools
  DEPENDS += +libpthread +zlib \
	+SQUASHFS_TOOLS_LZO_SUPPORT:liblzo \
	+SQUASHFS_TOOLS_LZ4_SUPPORT:liblz4 \
	+SQUASHFS_TOOLS_XZ_SUPPORT:liblzma
  MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
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
	XATTR_SUPPORT=

ifneq ($(CONFIG_SQUASHFS_TOOLS_XZ_SUPPORT),)
MAKE_FLAGS += XZ_SUPPORT=1
endif

ifneq ($(CONFIG_SQUASHFS_TOOLS_LZO_SUPPORT),)
MAKE_FLAGS += LZO_SUPPORT=1
endif

ifneq ($(CONFIG_SQUASHFS_TOOLS_LZ4_SUPPORT),)
MAKE_FLAGS += LZ4_SUPPORT=1
endif

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
endef

define Package/squashfs-tools-unsquashfs/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/squashfs-tools/unsquashfs $(1)/usr/sbin/unsquashfs
endef

$(eval $(call BuildPackage,squashfs-tools-mksquashfs))
$(eval $(call BuildPackage,squashfs-tools-unsquashfs))
