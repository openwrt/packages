#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libupnpp
PKG_VERSION:=1.0.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.lesbonscomptes.com/upmpdcli/downloads
PKG_HASH:=4738a19be51c09bd59a26b28e305172e2052c0e970b2fad92320a2d7cf1157c5

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libupnpp
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=https://www.lesbonscomptes.com/upmpdcli
  DEPENDS+=+libnpupnp +libcurl
  TITLE:=The libupnpp C++ library wraps libupnp for easier use by upmpdcli and upplay
endef

define Package/libupnpp/description
libupnpp defines useful objects over libupnp and can be used to create both devices
and control points. It is shared by upmpdcli and upplay.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libupnpp $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libupnpp.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libupnpp.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libupnpp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libupnpp.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libupnpp))
