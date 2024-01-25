#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=freetype
PKG_VERSION:=2.11.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/freetype
PKG_HASH:=3333ae7cfda88429c97a7ae63b7d01ab398076c3b67182e960e5684050f2c5c8

PKG_MAINTAINER:=Val Kulkov <val.kulkov@gmail.com>
PKG_LICENSE:=FTL GPL-2.0-only MIT ZLIB GPL-3.0-or-later
PKG_LICENSE_FILES:=docs/LICENSE.TXT docs/FTL.TXT docs/GPLv2.TXT src/bdf/README src/pcf/README src/gzip/zlib.h builds/unix/config.sub builds/unix/config.guess builds/unix/libtool 
PKG_CPE_ID:=cpe:/a:freetype:freetype

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libfreetype
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A free, high-quality and portable font engine
  URL:=http://www.freetype.org/
  DEPENDS:=+zlib +libpng
endef

define Package/libfreetype/description
 The FreeType project is a team of volunteers who develop free,
 portable and high-quality software solutions for digital typography.
 They specifically target embedded systems and focus on bringing small,
 efficient and ubiquitous products.
endef

MESON_ARGS += \
	-Dzlib=enabled \
	-Dbzip2=disabled \
	-Dpng=enabled \
	-Dharfbuzz=disabled \
	-Dbrotli=disabled \
	-Dmmap=enabled

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/freetype2
	$(CP) $(PKG_INSTALL_DIR)/usr/include/freetype2/* $(1)/usr/include/freetype2/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfreetype.{a,so}* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/freetype2.pc $(1)/usr/lib/pkgconfig/freetype2.pc
endef

define Package/libfreetype/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfreetype.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libfreetype))
