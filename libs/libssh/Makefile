#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_LICENSE:=LGPL-2.1-or-later BSD-2-Clause
PKG_MAINTAINER:=Mislav Novakovic <mislav.novakovic@sartura.hr>

PKG_NAME:=libssh
PKG_VERSION:=0.7.6
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.libssh.org/files/0.7/
PKG_HASH:=1d607d3859274f755942324afb0f887ee22edd157f9596a2e69e3a28ec6d1092

PKG_CPE_ID:=cpe:/a:libssh:libssh

CMAKE_INSTALL:=1

PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libssh
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=$(PKG_SOURCE_URL)
  TITLE:=SSH library
  DEPENDS:=+libpthread +librt +zlib +libopenssl
endef

define Package/libssh/description
 libssh is a mulitplatform C library implementing the SSHv2 and SSHv1 protocol
 for client and server implementations.
endef

CMAKE_OPTIONS = \
	-DHAVE_STRTOULL=1 \
	-DHAVE_GETADDRINFO=1 \
	-DHAVE_TERMIOS_H=1 \
	-DWITH_EXAMPLES:BOOL=OFF \
	-DWITH_GCRYPT:BOOL=OFF \
	-DWITH_GSSAPI:BOOL=OFF \
	-DWITH_LIBZ:BOOL=ON \
	-DWITH_NACL:BOOL=OFF \
	-DWITH_PCAP:BOOL=OFF \
	-DWITH_SERVER:BOOL=ON \
	-DWITH_SFTP:BOOL=ON \
	-DWITH_SSH1:BOOL=OFF \
	-DWITH_TESTING:BOOL=OFF \

ifeq ($(CONFIG_BIG_ENDIAN),y)
CMAKE_OPTIONS += -DWITH_BIG_ENDIAN=ON
else
CMAKE_OPTIONS += -DWITH_BIG_ENDIAN=OFF
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/libssh/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/libssh/* $(1)/usr/include/libssh/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libssh* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
endef

define Package/libssh/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libssh* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libssh))
