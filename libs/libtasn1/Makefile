#
# Copyright (C) 2005-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libtasn1
PKG_VERSION:=4.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=ftp://ftp.gnu.org/gnu/libtasn1
PKG_MD5SUM:=9a6767705725544f2b86670dcfb34107

#PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libtasn1
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=An ASN.1 and DER structures manipulation library
  MAINTAINER:=Nikos Mavrogiannopoulos <n.mavrogiannopoulos@gmail.com>
  URL:=ftp://ftp.gnu.org/gnu/libtasn1/
endef

define Package/libtasn1/description
 This is a library for Abstract Syntax Notation One (ASN.1) and
 Distinguish Encoding Rules (DER) manipulation.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
		--enable-shared \
		--enable-static

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libtasn1.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtasn1.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libtasn1*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libtasn1/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtasn1.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libtasn1))
