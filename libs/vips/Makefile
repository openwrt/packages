#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vips
PKG_VERSION:=8.17.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/libvips/libvips/releases/download/v$(PKG_VERSION)
PKG_HASH:=4d8c3325922c5300253d7594507a8f1d3caf8eed70dfb66cc7eb2cbed65bb5ca

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:libvips:libvips

PKG_BUILD_DEPENDS:=glib2/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/vips
  $(call Package/vips/Default)
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=An image manipulation library
  URL:=https://libvips.github.io/libvips/
  DEPENDS:=+glib2 +libexif +libexpat +libjpeg +libpng +giflib +libxml2
endef

MESON_ARGS += \
	-Ddocs=false \
	-Dcpp-docs=false \
	-Dintrospection=disabled \
	-Danalyze=false \
	-Dcfitsio=disabled \
	-Dfftw=disabled \
	-Darchive=disabled \
	-Dimagequant=disabled \
	-Dlcms=disabled \
	-Dwebp=disabled \
	-Dmagick=disabled \
	-Dmagick-package=disabled \
	-Dmatio=disabled \
	-Dnifti=disabled \
	-Dopenexr=disabled \
	-Dopenslide=disabled \
	-Dorc=disabled \
	-Dpangocairo=disabled \
	-Dpdfium=disabled \
	-Dpoppler=disabled \
	-Dppm=false \
	-Dradiance=false \
	-Drsvg=disabled \
	-Dtiff=disabled \
	-Dzlib=disabled \
	-Dcgif=enabled \
	-Djpeg=enabled \
	-Dexif=enabled \
	-Dpng=enabled \

TARGET_CXXFLAGS += -fno-rtti

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/vips
	$(CP) $(PKG_INSTALL_DIR)/usr/include/vips/* $(1)/usr/include/vips

	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libvips.so* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/vips.pc $(1)/usr/lib/pkgconfig/vips.pc
endef

define Package/vips/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libvips.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,vips))
