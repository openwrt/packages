# 
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libsoup
PKG_VERSION:=2.53.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/$(PKG_NAME)/2.53
PKG_MD5SUM:=dc23612d6365a0b8a6a650ffe0bdcb4c

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

TARGET_LDFLAGS+=\
	-Wl,-rpath-link=$(STAGING_DIR)/usr/lib $(if $(ICONV_FULL),-liconv)

define Package/libsoup
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libsoup
  URL:=http://live.gnome.org/LibSoup
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
  DEPENDS:=+glib2 +libxml2 +libgnutls +libsqlite3 $(ICONV_DEPENDS) $(INTL_DEPENDS)
endef

define Build/Configure
	$(call Build/Configure/Default, \
		--enable-ssl \
		--disable-glibtest \
		--without-apache-httpd \
		--without-gnome \
		--enable-vala=no \
	)
endef

define package/libsoup/decription
Libsoup is an HTTP library implementation in C
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{lib/pkgconfig,include/libsoup-2.4/libsoup}

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libsoup-2.4.{so*,la,a} \
		$(1)/usr/lib/

	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* \
		$(1)/usr/lib/pkgconfig/

	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/libsoup-2.4/libsoup/*.h \
		$(1)/usr/include/libsoup-2.4/libsoup/
endef

define Package/libsoup/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libsoup-2.4.so* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,libsoup))
