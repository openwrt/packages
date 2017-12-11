#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libgd
PKG_VERSION:=2.2.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/$(PKG_NAME)/$(PKG_NAME)/releases/download/gd-$(PKG_VERSION)/
PKG_HASH:=8c302ccbf467faec732f0741a859eef4ecae22fea2d2ab87467be940842bde51
PKG_MAINTAINER:=Jo-Philipp Wich <jo@mein.io>
PKG_LICENSE:=MIT

PKG_FIXUP:=autoreconf

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libgd
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libjpeg +libpng +LIBGD_TIFF:libtiff +LIBGD_FREETYPE:libfreetype
  TITLE:=The GD graphics library
  URL:=http://www.libgd.org/
  MENU:=1
endef

define Package/libgd/description
  GD is an open source code library for the dynamic creation of images by
  programmers. GD creates PNG, JPEG and GIF images, among other formats.
endef

define Package/libgd/config
	if PACKAGE_libgd
		config LIBGD_TIFF
			bool "TIFF image support"
			default n
			help
				Enable TIFF image support through libtiff
	endif
	if PACKAGE_libgd
		config LIBGD_FREETYPE
			bool "Freetype 2.x library support"
			default n
			help
				Enable Freetype 2.x font engine support through libfreetype
	endif
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--disable-rpath \
	--without-x \
	--without-fontconfig \
	--with-jpeg=$(STAGING_DIR)/usr \
	--with-png=$(STAGING_DIR)/usr \
	--without-xpm

ifdef CONFIG_LIBGD_TIFF
	CONFIGURE_ARGS+= \
		--with-tiff=$(STAGING_DIR)/usr
else
	CONFIGURE_ARGS+= \
		--without-tiff
endif

ifdef CONFIG_LIBGD_FREETYPE
	CONFIGURE_ARGS+= \
		--with-freetype=$(STAGING_DIR)/usr
else
	CONFIGURE_ARGS+= \
		--without-freetype
endif

CONFIGURE_VARS += \
	ac_cv_header_iconv_h=no

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/gdlib-config $(1)/usr/bin/
	$(SED) \
		's,^\(prefix\|exec_prefix\)=.*,\1=$(STAGING_DIR)/usr,g' \
		$(1)/usr/bin/gdlib-config
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/entities.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gd{,_color_map,_errors,_io,cache,fontg,fontl,fontmb,fonts,fontt,fx,pp}.h \
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
