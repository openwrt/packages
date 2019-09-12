#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vips
PKG_VERSION:=8.7.4
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/libvips/libvips/releases/download/v$(PKG_VERSION)
PKG_HASH:=ce7518a8f31b1d29a09b3d7c88e9852a5a2dcb3ee1501524ab477e433383f205

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:vips:vips

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/vips
  $(call Package/vips/Default)
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=An image manipulation library
  URL:=https://libvips.github.io/libvips/
  DEPENDS:=+glib2 +libexif +libexpat +libjpeg +libpng +giflib +libxml2 $(CXX_DEPENDS) $(INTL_DEPENDS)
endef

CONFIGURE_ARGS += \
	--disable-debug \
	--disable-gtk-doc-html \
	--disable-magickload \
	--disable-magicksave \
	--without-analyze \
	--without-cfitsio \
	--without-fftw \
	--without-gsf \
	--without-imagequant \
	--without-lcms \
	--without-libwebp \
	--without-magick \
	--without-magickpackage \
	--without-matio \
	--without-nifti \
	--without-OpenEXR \
	--without-openslide \
	--without-orc \
	--without-pangoft2 \
	--without-pdfium \
	--without-poppler \
	--without-ppm \
	--without-radiance \
	--without-rsvg \
	--without-tiff \
	--without-x \
	--without-zlib \
	--with-giflib \
	--with-jpeg \
	--with-libexif \
	--with-png \

TARGET_CXXFLAGS += -fno-rtti

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
