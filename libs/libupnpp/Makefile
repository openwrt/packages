#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libupnpp
PKG_VERSION:=0.9.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.lesbonscomptes.com/upmpdcli/downloads
PKG_MD5SUM:=ff218bbe2df6cf70b73843d951ef838e
PKG_MAINTAINER:=Petko Bordjukov <bordjukov@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libupnpp
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=http://www.lesbonscomptes.com/upmpdcli
  DEPENDS+= +libstdcpp +libexpat +librt +libcurl +libupnp
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
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libupnpp-$(PKG_VERSION).so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libupnpp.{so,la} $(1)/usr/lib/
endef

define Package/libupnpp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libupnpp-$(PKG_VERSION).so.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libupnpp.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libupnpp))
