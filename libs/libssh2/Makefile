#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libssh2
PKG_VERSION:=1.8.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.libssh2.org/download
PKG_HASH:=40b517f35b1bb869d0075b15125c7a015557f53a5a3a6a8bffb89b69fd70f159

PKG_FIXUP:=autoreconf

PKG_INSTALL:=1

PKG_LICENSE:=BSD
PKG_LICENSE_FILES:=COPYING

PKG_CONFIG_DEPENDS:= \
	CONFIG_LIBSSH2_MBEDTLS \
	CONFIG_LIBSSH2_OPENSSL

include $(INCLUDE_DIR)/package.mk

define Package/libssh2
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=SSH2 library
  URL:=https://www.libssh2.org/
  DEPENDS:=+LIBSSH2_MBEDTLS:libmbedtls +LIBSSH2_OPENSSL:libopenssl +zlib
  MAINTAINER:=Jiri Slachta <jiri@slachta.eu>
endef

define Package/libssh2/description
 libssh2 is a client-side C library implementing the SSH2 protocol.
endef

define Package/libssh2/config
	source "$(SOURCE)/Config.in"
endef

CONFIGURE_ARGS += \
	--disable-examples-build \
	--disable-silent-rules \
	$(if $(CONFIG_LIBSSH2_MBEDTLS),--with-mbedtls --with-libmbedtls-prefix=$(STAGING_DIR)/usr) \
	$(if $(CONFIG_LIBSSH2_OPENSSL),--with-openssl --with-libssl-prefix=$(STAGING_DIR)/usr) \
	--with-libz-prefix=$(STAGING_DIR)/usr

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libssh2.so* $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libssh2.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libssh2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libssh2.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libssh2))
