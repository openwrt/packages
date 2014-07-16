#
# Copyright (C) 2009-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# This Makefile is a skeleton
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libdmapsharing
PKG_VERSION:=2.9.15
PKG_RELEASE:=1

PKG_SOURCE:=libdmapsharing-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.flyn.org/projects/libdmapsharing/
PKG_MD5SUM:=52c9e4d3de931d9013eeaccf7371bb2d

PKG_BUILD_DIR:=$(BUILD_DIR)/libdmapsharing-$(PKG_VERSION)

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

TARGET_LDFLAGS+= \
	-Wl,-rpath-link=$(STAGING_DIR)/usr/lib

define Package/libdmapsharing
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libsoup +mdnsresponder +gstreamer +gst-plugins-base +libgstapp
  TITLE:=libdmapsharing
  URL:=http://www.flyn.org/projects/libdmapsharing/
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
endef

define Package/libdmapsharing/decription
  Libdmapsharing is a DMAP library implementation in C
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/libdmapsharing-3.0/ \
		$(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.so* \
		$(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/libdmapsharing/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.so* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,libdmapsharing))
