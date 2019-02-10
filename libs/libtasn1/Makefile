#
# Copyright (C) 2005-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libtasn1
PKG_VERSION:=4.13
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/$(PKG_NAME)
PKG_HASH:=7e528e8c317ddd156230c4e31d082cd13e7ddeb7a54824be82632209550c8cca

PKG_MAINTAINER:=Nikos Mavrogiannopoulos <n.mavrogiannopoulos@gmail.com>
PKG_LICENSE:=LGPLv2.1+
PKG_LICENSE_FILES:=COPYING.LIB

#PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libtasn1
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=An ASN.1 and DER structures manipulation library
  URL:=https://www.gnu.org/software/libtasn1/
endef

define Package/libtasn1/description
 This is a library for Abstract Syntax Notation One (ASN.1) and
 Distinguish Encoding Rules (DER) manipulation.
endef

TARGET_LDFLAGS += -Wl,--gc-sections

CONFIGURE_ARGS += \
	--disable-doc \
	--disable-gcc-warnings \
	--disable-ld-version-script \
	--disable-valgrind-tests

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
