#
# Copyright (C) 2010-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmicrohttpd
PKG_VERSION:=1.0.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/libmicrohttpd
PKG_HASH:=df324fcd0834175dab07483133902d9774a605bfa298025f69883288fd20a8c7

PKG_MAINTAINER:=Alexander Couzens <lynxis@fe80.eu>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:gnu:libmicrohttpd

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libmicrohttpd/default
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=https://www.gnu.org/software/libmicrohttpd/
endef

define Package/libmicrohttpd-no-ssl
$(call Package/libmicrohttpd/default)
  TITLE:=GNU libmicrohttpd is an embbeded HTTP server library
  VARIANT:=nossl
  DEFAULT_VARIANT:=1
  PROVIDES:=libmicrohttpd
endef

define Package/libmicrohttpd-ssl
$(call Package/libmicrohttpd/default)
  TITLE:=GNU libmicrohttpd is an embbeded HTTP and HTTPS server library
  VARIANT:=ssl
  DEPENDS:=+libgnutls
  PROVIDES:=libmicrohttpd
endef

define Package/libmicrohttpd/description
  GNU libmicrohttpd is a small C library that is supposed to make it easy
  to run an HTTP server as part of another application.
endef

CONFIGURE_ARGS += \
	--disable-curl \
	--disable-rpath \
	--disable-doc \
	--disable-examples \
	--enable-epoll \
	--with-pic

ifeq ($(BUILD_VARIANT),ssl)
CONFIGURE_ARGS += \
	--enable-https \
	--with-gnutls \
	--enable-md5=tlslib \
	--enable-sha256=tlslib
else
CONFIGURE_ARGS += \
	--disable-https \
	--without-gnutls
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/microhttpd.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmicrohttpd.{so*,a,la} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libmicrohttpd.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libmicrohttpd-no-ssl/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmicrohttpd.so* $(1)/usr/lib/
endef

define Package/libmicrohttpd-ssl/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmicrohttpd.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libmicrohttpd-no-ssl))
$(eval $(call BuildPackage,libmicrohttpd-ssl))
