#
# Copyright (C) 2011-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=jansson
PKG_VERSION:=2.10
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://www.digip.org/jansson/releases/
PKG_HASH:=241125a55f739cd713808c4e0089986b8c3da746da8b384952912ad659fa2f5a

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/jansson
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Jansson library
  URL:=http://www.digip.org/jansson/
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
endef

define Package/jansson/description
  Jansson is a C library for encoding, decoding and manipulating JSON data
endef

TARGET_CFLAGS += $(FPIC)
TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib -lm

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{lib,include}
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjansson* $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
endef

define Package/jansson/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjansson*so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,jansson))
