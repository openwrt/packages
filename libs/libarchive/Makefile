#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libarchive
PKG_VERSION:=3.1.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.libarchive.org/downloads
PKG_MD5SUM:=efad5a503f66329bb9d2f4308b5de98a
PKG_MAINTAINER:=Johannes Morgenroth <morgenroth@ibr.cs.tu-bs.de>
PKG_LICENSE:=BSD-2-Clause

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_BUILD_DEPENDS:=libxml2 libopenssl zlib

include $(INCLUDE_DIR)/package.mk

define Package/libarchive/Default
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=http://www.libarchive.org
endef

define Package/libarchive
  $(call Package/libarchive/Default)
  DEPENDS:=+libxml2 +libopenssl +zlib
  TITLE:=Multi-format archive and compression library
endef

define Package/libarchive/description
 Multi-format archive and compression library.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)
	$(CP) $(PKG_INSTALL_DIR)/* $(1)/
endef

define Package/libarchive/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libarchive.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libarchive))
