#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libarchive
PKG_VERSION:=3.4.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.libarchive.org/downloads
PKG_HASH:=d8e10494b4d3a15ae9d67a130d3ab869200cfd60b2ab533b391b0a0d5500ada1

PKG_MAINTAINER:=Johannes Morgenroth <morgenroth@ibr.cs.tu-bs.de>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:libarchive:libarchive

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libarchive/Default
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+zlib +liblzma +libbz2 +libexpat
  TITLE:=Multi-format archive and compression library
  URL:=https://www.libarchive.org/
endef

define Package/libarchive
  $(call Package/libarchive/Default)
  DEPENDS += +libopenssl
endef

define Package/libarchive-noopenssl
  $(call Package/libarchive/Default)
  TITLE += (without OpenSSL dependency)
  VARIANT:=noopenssl
endef

define Package/bsdtar/Default
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Compression
  TITLE:=tar BSD variant
  URL:=https://www.libarchive.org/
endef

define Package/bsdtar
  $(call Package/bsdtar/Default)
  DEPENDS:= +libarchive
endef

define Package/bsdtar-noopenssl
  $(call Package/bsdtar/Default)
  TITLE += (without OpenSSL dependency)
  DEPENDS:= +libarchive-noopenssl
  VARIANT:=noopenssl
endef

define Package/bsdtar/description
  Reads a variety of formats including tar, pax, zip, xar, lha, ar,
  cab, mtree, rar, warc, 7z and ISO images. Writes tar, pax, zip,
  xar, ar, ISO, mtree and shar archives. Automatically handles
  archives compressed with gzip, bzip2, lzip, xz, lzma or compress.
endef

CONFIGURE_ARGS += \
	--enable-bsdtar=shared \
	--disable-bsdcpio \
	--disable-rpath \
	--disable-acl \
	--disable-xattr \
	--without-cng \
	--without-iconv \
	--without-lz4 \
	--without-lzo2 \
	--without-nettle \
	--without-xml2 \
	--without-zstd

ifeq ($(BUILD_VARIANT),noopenssl)
	CONFIGURE_ARGS += --without-openssl
else
	CONFIGURE_ARGS += --with-openssl
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

define Package/libarchive/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so.* $(1)/usr/lib/
endef

define Package/bsdtar/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/bsdtar $(1)/usr/bin
endef

Package/libarchive-noopenssl/install = $(Package/libarchive/install)
Package/bsdtar-noopenssl/install = $(Package/bsdtar/install)

$(eval $(call BuildPackage,libarchive))
$(eval $(call BuildPackage,libarchive-noopenssl))
$(eval $(call BuildPackage,bsdtar))
$(eval $(call BuildPackage,bsdtar-noopenssl))
