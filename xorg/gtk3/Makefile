# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=gtk3
_PKG_NAME:=gtk+
PKG_VERSION:=3.91.2
_PKG_VERSION:=3.91
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://download.gnome.org/sources/$(_PKG_NAME)/$(_PKG_VERSION)
PKG_SOURCE:=$(_PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_HASH:=878a313f6de108c77ee1915ae8ce5ec4ba9c1f9e059a4a3bc1ed230ef29e4bc9

PKG_BUILD_DIR:=$(BUILD_DIR)/$(_PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=glib2 glib2/host gobject-introspection/host
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
#PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/gtk3
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libx11 +libxau +libxext +libxmu +libxaw +libxpm +libtiff +zlib \
	    +libexpat +pango +libxrandr +libxinerama +libxi +libxfixes +libxdamage \
	    +libepoxy +fontconfig +cairo +atk +gdk-pixbuf +graphene +at-spi2-atk
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
  --disable-cloudprint \
  --disable-papi \
  --disable-cups \
  --disable-glibtest


define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/include \
	  $(1)/usr/lib \
	  $(1)/usr/share

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/include/* \
	  $(1)/usr/include/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/{pkgconfig,*.so*} \
	  $(1)/usr/lib/
endef

define Package/gtk3/install
	$(INSTALL_DIR) \
	  $(1)/usr/bin \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/bin/* \
	  $(1)/usr/bin/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/*.so* \
	  $(1)/usr/lib/
endef

$(eval $(call BuildPackage,gtk3))
