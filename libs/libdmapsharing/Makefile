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
PKG_VERSION:=3.9.7
PKG_RELEASE:=1

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_LICENSE:=LGPLv2.1
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=libdmapsharing-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.flyn.org/projects/libdmapsharing/
PKG_HASH:=745f4dc0b00db3e40721d041c883d813489814eaad3ca0f9ffb091e7e1acfa88

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

TARGET_LDFLAGS+= \
	-Wl,-rpath-link=$(STAGING_DIR)/usr/lib

define Package/libdmapsharing
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libsoup +mdnsresponder +gstreamer1-libs +gstreamer1-plugins-base +gst1-mod-app
  TITLE:=libdmapsharing
  URL:=https://www.flyn.org/projects/libdmapsharing/
endef

define Package/libdmapsharing/decription
  Libdmapsharing is a DMAP library implementation in C
endef

CONFIGURE_ARGS += \
	--disable-check \
	--disable-gtk-doc \
	--disable-introspection

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/libdmapsharing-4.0/ \
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
