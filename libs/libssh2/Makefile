#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libssh2
PKG_VERSION:=1.9.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.libssh2.org/download
PKG_HASH:=d5fb8bd563305fd1074dda90bd053fb2d29fc4bce048d182f96eaa466dfadafd

PKG_MAINTAINER:=Jiri Slachta <jiri@slachta.eu>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:libssh2:libssh2

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libssh2/Default
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=SSH2 library
  URL:=https://www.libssh2.org/
  DEPENDS:=+zlib
  PROVIDES:=libssh2
  ABI_VERSION:=1
endef

define Package/libssh2-mbedtls
$(call Package/libssh2/Default)
  TITLE+= (mbedtls)
  DEPENDS+= +PACKAGE_libssh2-mbedtls:libmbedtls
  VARIANT:=mbedtls
  DEFAULT_VARIANT:=1
endef

define Package/libssh2-openssl
$(call Package/libssh2/Default)
  TITLE+= (openssl)
  DEPENDS+= +PACKAGE_libssh2-openssl:libopenssl
  VARIANT:=openssl
endef

define Package/libssh2/Default/description
  libssh2 is a client-side C library implementing the SSH2 protocol.
endef

define Package/libssh2-mbedtls/description
$(call Package/libssh2/Default/description)

  This package contains libssh2 compiled with support for mbed TLS.
endef

define Package/libssh2-openssl/description
$(call Package/libssh2/Default/description)

  This package contains libssh2 compiled with support for OpenSSL.
endef

ifeq ($(BUILD_VARIANT),mbedtls)
  LIBSSH2_CRYPTO_BACKEND:=mbedTLS
else ifeq ($(BUILD_VARIANT),openssl)
  LIBSSH2_CRYPTO_BACKEND:=OpenSSL
endif

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_TESTING=OFF \
	-DENABLE_ZLIB_COMPRESSION=ON \
	-DCLEAR_MEMORY=ON \
	-DCRYPTO_BACKEND=$(LIBSSH2_CRYPTO_BACKEND)

define Package/libssh2/Default/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libssh2.so.$(ABI_VERSION)* $(1)/usr/lib/
endef

Package/libssh2-mbedtls/install=$(Package/libssh2/Default/install)
Package/libssh2-openssl/install=$(Package/libssh2/Default/install)

$(eval $(call BuildPackage,libssh2-mbedtls))
$(eval $(call BuildPackage,libssh2-openssl))
