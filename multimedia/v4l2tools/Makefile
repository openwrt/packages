# This software is in the public domain, furnished "as is", without technical
# support, and with no warranty, express or implied, as to its usefulness for
# any purpose.

include $(TOPDIR)/rules.mk

PKG_NAME:=v4l2tools
PKG_VERSION:=0.1.8
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mpromonet/v4l2tools.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=5d848ab811126e9ad11cc374e312e460cebe40fab99164d4368fe0e69dc07997

PKG_MAINTAINER:=Michel Promonet<michel.promonet@free.fr>
PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENCE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

PKG_CONFIG_DEPENDS := CONFIG_PACKAGE_libvpx

define Package/v4l2tools
	SECTION:=multimedia
	CATEGORY:=Multimedia
	TITLE:=v4l2tools
	DEPENDS:=+libstdcpp +libjpeg +PACKAGE_libvpx:libvpx
	URL:=https://github.com/mpromonet/v4l2tools
endef

CMAKE_OPTIONS += \
       -DWITH_JPEG=ON \
       -DWITH_VPX=$(if $(CONFIG_PACKAGE_libvpx),ON,OFF) \
       -DWITH_X264=OFF \
       -DWITH_X265=OFF 

define Package/v4l2tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/v4l2tools-$(PKG_VERSION) $(1)/usr/bin/v4l2tools
endef

$(eval $(call BuildPackage,v4l2tools))
