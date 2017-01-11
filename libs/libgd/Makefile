#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libgd
PKG_VERSION:=2.1.1
PKG_RELEASE:=1

PKG_SOURCE:=gd-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/libgd/libgd/archive
PKG_MD5SUM:=e91a1a99903e460e7ba00a794e72cc1e
PKG_MAINTAINER:=Jo-Philipp Wich <jo@mein.io>
PKG_LICENSE:=MIT

PKG_FIXUP:=autoreconf

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/libgd-gd-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/libgd
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libjpeg +libpng
  TITLE:=The GD graphics library
  URL:=http://www.libgd.org/
endef

define Package/libgd/description
  GD is an open source code library for the dynamic creation of images by
  programmers. GD creates PNG, JPEG and GIF images, among other formats.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--disable-rpath \
	--without-x \
	--without-fontconfig \
	--without-freetype \
	--with-jpeg=$(STAGING_DIR)/usr \
	--with-png=$(STAGING_DIR)/usr \
	--with-vpx=no \
	--without-xpm \
	--without-iconv

CONFIGURE_VARS += \
	LIBPNG12_CONFIG="$(STAGING_DIR_HOSTPKG)/bin/libpng12-config" \
	ac_cv_header_iconv_h=no

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/gdlib-config $(1)/usr/bin/
	$(SED) \
		's,^\(prefix\|exec_prefix\)=.*,\1=$(STAGING_DIR)/usr,g' \
		$(1)/usr/bin/gdlib-config
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/entities.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gd{,_io,cache,fontg,fontl,fontmb,fonts,fontt,fx}.h \
		$(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgd.{a,la,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(2)/bin
	$(LN) ../../usr/bin/gdlib-config $(2)/bin/
endef

define Package/libgd/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgd.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libgd))
