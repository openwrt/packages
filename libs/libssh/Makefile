#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libssh
PKG_VERSION:=0.10.6
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.libssh.org/files/0.10/
PKG_HASH:=1861d498f5b6f1741b6abc73e608478491edcf9c9d4b6630eef6e74596de9dc1

PKG_MAINTAINER:=
PKG_LICENSE:=LGPL-2.1-or-later BSD-2-Clause
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:libssh:libssh

CMAKE_INSTALL:=1
CMAKE_BINARY_SUBDIR:=build
PKG_BUILD_FLAGS:=no-mips16

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libssh
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=$(PKG_SOURCE_URL)
  TITLE:=SSH library
  DEPENDS:=+libpthread +librt +zlib +libmbedtls
endef

define Package/libssh/description
 libssh is a mulitplatform C library implementing the SSHv2 and SSHv1 protocol
 for client and server implementations.
endef

CMAKE_OPTIONS += \
	-DHAVE_STRTOULL=1 \
	-DHAVE_GETADDRINFO=1 \
	-DHAVE_TERMIOS_H=1 \
	-DWITH_EXAMPLES:BOOL=OFF \
	-DWITH_GCRYPT:BOOL=OFF \
	-DWITH_MBEDTLS:BOOL=ON \
	-DWITH_GSSAPI:BOOL=OFF \
	-DWITH_LIBZ:BOOL=ON \
	-DWITH_NACL:BOOL=OFF \
	-DWITH_PCAP:BOOL=OFF \
	-DWITH_SERVER:BOOL=ON \
	-DWITH_SFTP:BOOL=ON \
	-UWITH_STACK_CLASH_PROTECTION \
	-DWITH_STACK_CLASH_PROTECTION=0 \
	-UWITH_STACK_PROTECTOR \
	-DWITH_STACK_PROTECTOR=0 \
	-UWITH_STACK_PROTECTOR_STRONG \
	-DWITH_STACK_PROTECTOR_STRONG=0 \
	-DHAVE_WORDS_BIGENDIAN=$(if $(CONFIG_BIG_ENDIAN),1,0)

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/libssh.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/libssh.pc
endef

define Package/libssh/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libssh* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libssh))
