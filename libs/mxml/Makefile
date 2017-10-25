#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mxml
PKG_VERSION:=2.10
PKG_RELEASE:=1
PKG_HASH:=267ff58b64ddc767170d71dab0c729c06f45e1df9a9b6f75180b564f09767891

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/michaelrsweet/mxml/releases/download/release-$(PKG_VERSION)/
PKG_FIXUP:=autoreconf

PKG_MAINTAINER:=Espen Jürgensen <espenjurgensen+openwrt@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/mxml
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Mini-XML
  URL:=http://www.minixml.org/
endef

define Package/mxml/description
  A small xml library.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static

define Build/InstallDev
	mkdir -p $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/mxml.h $(1)/usr/include/
	mkdir -p $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libmxml.so* $(1)/usr/lib/
	mkdir -p $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/mxml.pc $(1)/usr/lib/pkgconfig/
endef

define Package/mxml/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libmxml.so.*  $(1)/usr/lib/
endef

$(eval $(call BuildPackage,mxml))
