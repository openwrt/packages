# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=gtk2
_PKG_NAME:=gtk+
PKG_VERSION:=2.24.32
_PKG_VERSION:=2.24
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://download.gnome.org/sources/$(_PKG_NAME)/$(_PKG_VERSION)
PKG_SOURCE:=$(_PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_HASH:=b6c8a93ddda5eabe3bfee1eb39636c9a03d2a56c7b62828b359bf197943c582e

PKG_BUILD_DIR:=$(BUILD_DIR)/$(_PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=glib2 glib2/host gobject-introspection/host
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_FIXUP:=libtool

include $(INCLUDE_DIR)/package.mk

define Package/gtk2
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libx11 +libxau +libxext +libxmu +libxaw +libxpm +libtiff +zlib \
	    +libexpat +pango +libxrandr +libxinerama +libxi +libxfixes +libxdamage \
	    +fontconfig +cairo +atk +gdk-pixbuf +at-spi2-atk
  TITLE:=The GTK plus Toolkit (v3)
  URL:=https://www.gtk.org/
endef

MAKE_FLAGS+= \
  GLIB_COMPILE_RESOURCES=$(STAGING_DIR_HOSTPKG)/bin/glib-compile-resources \
  GLIB_MKENUMS=$(STAGING_DIR_HOSTPKG)/bin/glib-mkenums \
  GLIB_GENMARSHAL=$(STAGING_DIR_HOSTPKG)/bin/glib-genmarshal

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CONFIGURE_ARGS += \
  --prefix=/usr \
  --disable-papi \
  --disable-cups \
  --disable-glibtest\
  --with-xinput=yes \
  --without-libjasper \
  --with-included-loaders=png \
  --with-gdktarget=x11


define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/include \
	  $(1)/usr/lib \
	  $(1)/usr/share

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/include/* \
	  $(1)/usr/include/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/gtk-2.0/include/* \
	  $(1)/usr/include/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/{pkgconfig,*.so*} \
	  $(1)/usr/lib/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share/aclocal \
	  $(1)/usr/share/
endef

define Package/gtk2/install
	$(INSTALL_DIR) \
	  $(1)/usr/bin \
	  $(1)/usr/lib \
	  $(1)/usr/share

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/bin/* \
	  $(1)/usr/bin/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/*.so* \
	  $(1)/usr/lib/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share/themes \
	  $(1)/usr/share/

endef

$(eval $(call BuildPackage,gtk2))
