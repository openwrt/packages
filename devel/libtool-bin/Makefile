#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libtool
PKG_VERSION:=2.4.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/libtool
PKG_MD5SUM:=addf44b646ddb4e3919805aa88fa7c5e
PKG_MAINTAINER:=Heinrich Schuchardt <xypron.glpk@gmx.de>
PKG_LICENSE:=GPL-2.0+
PKG_BUILD_DIR = $(BUILD_DIR)/libtool-bin/$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libtool-bin
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=GNU Libtool - libtoolize
  URL:=https://www.gnu.org/software/libtool/
endef

define Package/libtool-bin/description
 GNU libtool is a generic library support script.
 Libtool hides the complexity of using shared libraries behind a consistent,
 portable interface. 
 This package contains the libtoolize executable.
endef

define Package/libtool-bin/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/libtoolize $(1)/usr/bin/
	$(SED) 's|$(STAGING_DIR_HOST)||g' $(1)/usr/bin/libtoolize
	$(INSTALL_DIR) $(1)/usr/share/aclocal/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/aclocal/*.m4 \
	  $(1)/usr/share/aclocal/
	$(INSTALL_DIR) $(1)/usr/share/libtool/build-aux/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/libtool/build-aux/* \
	  $(1)/usr/share/libtool/build-aux/
endef

$(eval $(call BuildPackage,libtool-bin))
