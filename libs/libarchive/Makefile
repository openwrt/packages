#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libarchive
PKG_VERSION:=3.3.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.libarchive.org/downloads
PKG_HASH:=ed2dbd6954792b2c054ccf8ec4b330a54b85904a80cef477a1c74643ddafa0ce
PKG_MAINTAINER:=Johannes Morgenroth <morgenroth@ibr.cs.tu-bs.de>
PKG_LICENSE:=BSD-2-Clause

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/libarchive/Default
	SECTION:=libs
	CATEGORY:=Libraries
	DEPENDS:=+zlib +liblzma +libbz2 +libexpat
	TITLE:=Multi-format archive and compression library
	URL:=http://www.libarchive.org/
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

define Package/bsdtar
	SECTION:=utils
	CATEGORY:=Utilities
	SUBMENU:=Compression
	DEPENDS:=+libarchive-noopenssl
	TITLE:=BSD variant that supports various file compression formats
	URL:=http://www.libarchive.org/
endef

define Package/bsdtar/description
	Reads a variety of formats including tar, pax, zip, xar, lha, ar,
	cab, mtree, rar, warc, 7z and ISO images. Writes tar, pax, zip,
	xar, ar, ISO, mtree and shar archives. Automatically handles
	archives compressed with gzip, bzip2, lzip, xz, lzma or compress.
endef

CONFIGURE_ARGS += \
	--disable-bsdcpio \
	--enable-bsdtar=shared \
	--disable-acl \
	--disable-xattr \
	--without-nettle \
	--without-xml2 \
	--without-lz4 \
	--without-cng \

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

$(eval $(call BuildPackage,libarchive))
$(eval $(call BuildPackage,libarchive-noopenssl))
$(eval $(call BuildPackage,bsdtar))
