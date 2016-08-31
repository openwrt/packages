#
# Copyright (C) 2010-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vips
PKG_VERSION:=7.42.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.vips.ecs.soton.ac.uk/supported/7.42/
PKG_MD5SUM:=33a4590924b3120ce309982ec85a7c16
PKG_FIXUP:=autoreconf
PKG_CHECK_FORMAT_SECURITY:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

PKG_INSTALL=1

define Package/vips
  $(call Package/vips/Default)
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=An image manipulation library
  URL:=http://www.vips.ecs.soton.ac.uk/
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
  DEPENDS:=+glib2 +libexif +libjpeg +libpng +libxml2 $(INTL_DEPENDS)
endef

TARGET_LDFLAGS+= \
	-Wl,-rpath-link=$(STAGING_DIR)/usr/lib

CONFIGURE_ARGS += \
	--disable-cxx \
	--disable-threads \
	--without-cfitsio \
	--without-fftw \
	--without-lcms \
	--without-magick \
	--without-matio \
	--without-OpenEXR \
	--without-orc \
	--without-pangoft2 \
	--without-python \
	--without-tiff \
	--without-v4l \
	--without-x \
	--without-zip \
	--with-jpeg \
	--with-libexif \
	--with-png \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/vips
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/* \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.so* \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* \
		$(1)/usr/lib/pkgconfig/
endef

define Package/vips/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.so* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,vips))
