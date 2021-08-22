include $(TOPDIR)/rules.mk

PKG_NAME:=cairo
PKG_VERSION:=1.16.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://cairo.freedesktop.org/releases/
PKG_HASH:=5e7b29b3f113ef870d1e3ecf8adf21f923396401604bda16d44be45e66052331

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=LGPL-2.1-or-later MPL-1.1
PKG_LICENSE_FILES:=COPYING COPYING-LGPL-2.1 COPYING-MPL-1.1

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libcairo
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Video
  TITLE:=cairo
  URL:=https://cairo.freedesktop.org/
  DEPENDS:=+libpng +libfreetype +fontconfig +libmesa +pixman +glib2 +libjpeg +zlib
endef

define Package/libcairo/description
  Cairo is a 2D graphics library with support for multiple output devices.
endef

CONFIGURE_ARGS += \
	--oldincludedir="$(STAGING_DIR)/usr/include" \
	--x-includes="$(STAGING_DIR)/usr/include" \
	--x-libraries="$(STAGING_DIR)/usr/lib" \
	--without-x \
	--without-gallium \
	--enable-pdf \
	--enable-png \
	--enable-ps \
	--enable-svg \
	--enable-tee \
	--enable-ft \
	--enable-glesv3 \
	--enable-test-surfaces=no \
	--enable-drm=no \
	--enable-gallium=no \
	--enable-x=no \
	--enable-xcb=no \
	--enable-xlib-xrender=no \
	--enable-xcb=no \
	--enable-xlib-xcb=no \
	--enable-xcb-shm=no

define Package/libcairo/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/cairo
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cairo/*.so $(1)/usr/lib/cairo
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/cairo
	$(CP) $(PKG_INSTALL_DIR)/usr/include/cairo/*.h $(1)/usr/include/cairo
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/cairo
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cairo/*.so $(1)/usr/lib/cairo
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig
endef

$(eval $(call BuildPackage,libcairo))
