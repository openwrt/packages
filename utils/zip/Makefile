#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zip
PKG_REV:=30
PKG_VERSION:=3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)$(PKG_REV).tar.gz
PKG_SOURCE_URL:=@SF/infozip
PKG_MD5SUM:=7b74551e63f8ee6aab6fbc86676c0d37
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

PKG_LICENSE:=BSD-4-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/zip$(PKG_REV)
PKG_CHECK_FORMAT_SECURITY:=0

include $(INCLUDE_DIR)/package.mk

define Package/zip
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=
  TITLE:=Archiver for .zip files
  URL:=http://infozip.sourceforge.net/Zip.html
  SUBMENU:=Compression
endef

define Package/zip/description
	This is InfoZIP's zip program. It produces files that are fully
	compatible with the popular PKZIP program; however, the command line
	options are not identical. In other words, the end result is the same,
	but the methods differ.
endef

define Build/Configure
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) -f unix/Makefile generic \
		prefix="$(PKG_INSTALL_DIR)/usr" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CC="$(TARGET_CC) $(TARGET_CFLAGS) -O $(TARGET_CPPFLAGS) -I. -DUNIX" \
		LD="$(TARGET_CC) $(TARGET_LDFLAGS)" \
		IZ_BZIP2="no" \
		install
endef

define Package/zip/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,zip))
