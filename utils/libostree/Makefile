#
# Copyright (C) 2024 Muhamad Aji Wibisono <muhamadajiw71@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libostree
PKG_VERSION:=2024.8
PKG_RELEASE:=1

PKG_MAINTAINER:=Muhamad Aji Wibisono <muhamadajiw71@gmail.com>
PKG_LICENSE:=GPL-2.0-only

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/ostreedev/ostree/releases/download/v$(PKG_VERSION)/
PKG_HASH:=e2136e116669f114ff7349f12e299f63c0bece733451649414a8dcd85b863c3f

PKG_INSTALL:=1

TARGET_CFLAGS += -Wno-format-nonliteral

include $(INCLUDE_DIR)/package.mk

define Package/libostree
	SECTION:=utils
	CATEGORY:=Utilities
	DEPENDS:=+glib2 +libarchive +libsoup3 +libgpgme +fuse3-utils +libmount +libe2p
	TITLE:=a git-like suite for bootable filesystem trees
	URL:=https://ostreedev.github.io/ostree/
endef

define Package/libostree/description
 OSTree is a suite tools that combines a “git-like” model for committing and downloading bootable filesystem trees.
 along with a layer for deploying them and managing the bootloader configuration.
endef

CONFIGURE_ARGS += \
		--without-selinux \
		--disable-man \
		--with-soup3 \
		--with-gpgme \

define Package/libostree/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ostree $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rofiles-fuse $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/ostree
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/ostree/ostree-prepare-root $(1)/usr/lib/ostree
endef

$(eval $(call BuildPackage,libostree))
