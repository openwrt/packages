#
# Copyright (C) 2006-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libexecinfo
PKG_VERSION:=1.1
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://distcache.freebsd.org/local-distfiles/itetcu
PKG_HASH:=c9a21913e7fdac8ef6b33250b167aa1fc0a7b8a175145e26913a4c19d8a59b1f

PKG_LICENSE:=BSD
PKG_LICENSE_FILES:=README

PKG_MAINTAINER:=Robert Nemeti <nrobert13@gmail.com>

PKG_INSTALL:=2

include $(INCLUDE_DIR)/package.mk

define Package/libexecinfo
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library implementing glibc's backtrace
  URL:=https://www.freshports.org/devel/libexecinfo
endef

define Package/libexecinfo-dev
  SECTION:=devel
  CATEGORY:=Development
  SUBMENU:=Libraries
  DEPENDS:=libexecinfo
  TITLE:=Development files for the libexecinfo library
endef

define Package/libexecinfo/description
 libexecinfo is a quick-n-dirty BSD licensed clone of the GNU libc backtrace facility
 This package includes the shared library.
endef

define Package/libexecinfo-dev/description
 libexecinfo is a quick-n-dirty BSD licensed clone of the GNU libc backtrace facility
 This package includes the development support files.
endef

TARGET_CFLAGS += -fno-omit-frame-pointer

define Build/Install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/execinfo.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/stacktraverse.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libexecinfo.{a,so*} $(1)/usr/lib/
	$(LN) libexecinfo.so.1 $(1)/usr/lib/libexecinfo.so
endef

define Package/libexecinfo/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libexecinfo.so.1 $(1)/usr/lib/
	$(LN) libexecinfo.so.1 $(1)/usr/lib/libexecinfo.so
endef

define Package/libexecinfo-dev/install
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/execinfo.h $(1)/usr/include/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/stacktraverse.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)//libexecinfo.a $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libexecinfo))
$(eval $(call BuildPackage,libexecinfo-dev))
