#
# Copyright (C) 2016 Nikil Mehta <nikil.mehta@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libslang2
PKG_VERSION:=2.3.1a
PKG_RELEASE:=1

PKG_SOURCE:=slang-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://www.jedsoft.org/releases/slang/
PKG_MD5SUM:=54f0c3007fde918039c058965dffdfd6c5aec0bad0f4227192cc486021f08c36

PKG_MAINTAINER:=Nikil Mehta <nikil.mehta@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DIR:=$(BUILD_DIR)/slang-$(PKG_VERSION)
PKG_INSTALL:=1 

include $(INCLUDE_DIR)/package.mk

define Package/libslang2
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=S-Lang programming library - runtime version
  URL:=http://www.s-lang.org/
  DEPENDS:=+libpcre +libpng +zlib
endef

define Package/libslang2/description
	S-Lang is a C programmer's library that includes routines for the rapid
	development of sophisticated, user friendly, multi-platform applications.
	.
	This package contains only the shared library libslang.so.* and copyright
	information. It is only necessary for programs that use this library (such
	as jed and slrn). If you plan on doing development with S-Lang, you will
	need the companion -dev package as well.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libslang.so* $(1)/usr/lib/
endef

define Package/libslang2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libslang.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/slang/ $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libslang2))
