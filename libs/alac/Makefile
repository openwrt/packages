#
# Copyright (C) 2016 OpenWrt.org  
#
# This is free software, licensed under the GNU General Public License v2 and the Apple Public Source License v2.0

# Please see LICENSE and APPLE_LICENSE.txt for more information.
# 
#

include $(TOPDIR)/rules.mk

PKG_NAME:=alac
PKG_VERSION:=0.0.7
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mikebrady/alac
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_LICENSE:=APSL-2.0 Apache-2.0

PKG_BUILD_PARALLEL:=1

PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=autogen.sh
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libalac
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=The Apple Lossless Audio Codec Library
  URL:=http://alac.macosforge.org
  MAINTAINER:=Mike Brady <mikebrady@eircom.net>
  DEPENDS:= +libstdcpp
endef

define Package/libalac/description
  The Apple Lossless Audio Codec (ALAC) is an audio codec developed by Apple and supported on iPhone, iPad, most iPods, Mac and iTunes.
  ALAC is a data compression method which reduces the size of audio files with no loss of information.
  A decoded ALAC stream is bit-for-bit identical to the original uncompressed audio file.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/alac $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libalac.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libalac.la $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libalac.a $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/ $(1)/usr/lib/pkgconfig/
endef

define Package/libalac/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libalac.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libalac.la $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libalac))
