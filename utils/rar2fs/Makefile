#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rar2fs
PKG_VERSION:=1.22.0
PKG_RELEASE:=1

PKG_SOURCE:=rar2fs-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/hasse69/rar2fs/releases/download/v$(PKG_VERSION)
PKG_MD5SUM:=56b374b95d6d56dc94f24997749294fe
PKG_MAINTAINER:=Nikolay Podoprigora <volzhanin@gmail.com>

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--with-unrar=$(STAGING_DIR)/usr/include/unrar

define Package/rar2fs
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Filesystem
  TITLE:=rar2fs
  URL:=https://github.com/hasse69/rar2fs
  DEPENDS:=+libstdcpp +libfuse +libunrar
endef

define Package/rar2fs/description
	FUSE file system for reading RAR archives
endef

define Package/rar2fs/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{rar2fs,mkr2i} $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(LN) /usr/bin/rar2fs $(1)/usr/sbin/mount.rar2fs
endef

$(eval $(call BuildPackage,rar2fs))
