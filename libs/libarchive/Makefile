#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libarchive
PKG_VERSION:=3.7.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.libarchive.org/downloads
PKG_HASH:=ed8b5732e4cd6e30fae909fb945cad8ff9cb7be5c6cdaa3944ec96e4a200c04c

PKG_MAINTAINER:=Johannes Morgenroth <morgenroth@ibr.cs.tu-bs.de>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:libarchive:libarchive

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

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
  CONFLICTS:=libarchive-noopenssl
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
  CONFLICTS:=bsdtar-noopenssl
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

CMAKE_OPTIONS += \
	-DENABLE_LIBB2=OFF \
	-DENABLE_LZ4=OFF \
	\
	-DENABLE_ZSTD=OFF \
	-DENABLE_LIBXML2=OFF \
	-DENABLE_PCREPOSIX=OFF \
	-DENABLE_PCRE2POSIX=OFF \
	-DENABLE_LibGCC=OFF \
	-DENABLE_CNG=OFF \
	\
	-DENABLE_TAR_SHARED=ON \
	-DENABLE_CPIO=OFF \
	-DENABLE_CAT=OFF \
	-DENABLE_XATTR=OFF \
	-DENABLE_ACL=OFF \
	-DENABLE_ICONV=OFF \
	-DENABLE_TEST=OFF

ifeq ($(BUILD_VARIANT),noopenssl)
	CMAKE_OPTIONS += -DENABLE_OPENSSL=OFF
else
	CMAKE_OPTIONS += -DENABLE_OPENSSL=ON
endif

EXTRA_CFLAGS += "-I$(PKG_BUILD_DIR)/extra-includes"

define Build/Configure
	$(INSTALL_DIR) $(PKG_BUILD_DIR)/extra-includes/
	$(CP) -R $(STAGING_DIR_HOST)/include/ext2fs $(PKG_BUILD_DIR)/extra-includes/
	$(Build/Configure/Default)
endef

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
