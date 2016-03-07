#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pkg-config
PKG_VERSION:=0.29.1
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://pkgconfig.freedesktop.org/releases/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=f739a28cae4e0ca291f82d1d41ef107d
PKG_MAINTAINER:=Heinrich Schuchardt <xypron.glpk@gmx.de>
PKG_LICENSE:=GPL-2+

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/pkg-config
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=pkg-config
  URL:=http://www.freedesktop.org/wiki/Software/pkg-config/
  DEPENDS:=+glib2 $(INTL_DEPENDS)
endef

define Package/pkg-config/description
  pkg-config is a helper tool used when compiling applications and libraries.
  It helps you insert the correct compiler options on the command line so an
  application can use gcc -o test test.cpkg-config --libs --cflags glib-2.0
  for instance, rather than hard-coding values on where to find glib (or
  other libraries).
endef

define Package/pkg-config/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pkg-config $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/share/aclocal/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/aclocal/pkg.m4 \
	  $(1)/usr/share/aclocal/
endef

$(eval $(call BuildPackage,pkg-config))
