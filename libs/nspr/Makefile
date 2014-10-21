#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nspr
PKG_VERSION:=3.16.6
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/nss-$(PKG_VERSION)
PKG_SOURCE:=nss-$(PKG_VERSION)-with-nspr-4.10.6.tar.gz
PKG_SOURCE_URL:=ftp://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_3_16_6_RTM/src/
PKG_MD5SUM:=4722706ea101948712b5ad003629679f
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

CONFIGURE_PATH=nspr
MAKE_PATH=nspr

define Package/nspr
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Netscape Portable Runtime (NSPR)
  URL:=https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSPR
  DEPENDS:=+libpthread +librt
  MAINTAINER:=Luka Perkov <luka@openwrt.org>
endef

define Package/nspr/description
  Netscape Portable Runtime (NSPR) provides a platform-neutral API for system
  level and libc-like functions. The API is used in the Mozilla clients, many of
  Red Hat's and Sun's server applications, and other software offerings.
endef

CONFIGURE_ARGS += \
	--with-arch=toolchain-default \
	--with-fpu=toolchain-default \
	--with-float-abi=toolchain-default \
	--with-soft-float=toolchain-default

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/ $(1)/usr/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*{a,so} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/nspr.pc $(1)/usr/lib/pkgconfig/
endef

define Package/nspr/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*so $(1)/usr/lib
endef

$(eval $(call BuildPackage,nspr))
