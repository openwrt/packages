#
# Copyright (C) 2010-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmicrohttpd
PKG_VERSION:=0.9.52
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/libmicrohttpd
PKG_MD5SUM:=54797f6e763d417627f89f60e4ae0a431dab0523f92f83def23ea02d0defafea

PKG_MAINTAINER:=Alexander Couzens <lynxis@fe80.eu>

PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libmicrohttpd/Default
   SECTION:=libs
   CATEGORY:=Libraries
   TITLE:=GNU libmicrohttpd is a library that runs an HTTP server.
   URL:=http://www.gnu.org/software/libmicrohttpd/
endef

define Package/libmicrohttpd
$(call Package/libmicrohttpd/Default)
   TITLE+=(with-ssl)
   DEPENDS:=+libpthread +libgcrypt +libgnutls +libgpg-error
endef

define Package/libmicrohttpd-no-ssl
$(call Package/libmicrohttpd/Default)
   TITLE+=(no-ssl)
   DEPENDS:=+libpthread
   VARIANT:=no-ssl
   CONFLICTS:=libmicrohttpd
endef

define Package/libmicrohttpd/description/Default
	GNU libmicrohttpd is a small C library that is supposed to make it easy
	to run an HTTP server as part of another application.
endef

define Package/libmicrohttpd-no-ssl/description
$(call Package/libmicrohttp/description/Default)
endef

CONFIGURE_ARGS+= \
	--disable-curl \
	--disable-spdy \
	--without-openssl

ifeq ($(BUILD_VARIANT),no-ssl)
CONFIGURE_ARGS += \
	--disable-https \
	--without-gnutls
else
CONFIGURE_ARGS += \
	--enable-https \
	--with-gnutls
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{so*,a,la} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
endef

define Package/libmicrohttpd/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

define Package/libmicrohttpd-no-ssl/install
$(call Package/libmicrohttpd/install,$1)
endef

$(eval $(call BuildPackage,libmicrohttpd))
$(eval $(call BuildPackage,libmicrohttpd-no-ssl))
