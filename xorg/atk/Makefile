# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=atk
PKG_VERSION:=2.28.1
_PKG_VERSION:=2.28
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://download.gnome.org/sources/$(PKG_NAME)/$(_PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_HASH:=cd3a1ea6ecc268a2497f0cd018e970860de24a6d42086919d6bf6c8e8d53f4fc

#HOST_BUILD_DEPENDS:=util-macros/host mkfontscale/host
PKG_BUILD_DEPENDS:=glib2/host
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/atk
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+glib2
  TITLE:=A library providing a set of interfaces for accessibility
  URL:=https://www.gtk.org/
endef

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

MAKE_FLAGS+= \
  GLIB_COMPILE_RESOURCES=$(STAGING_DIR_HOSTPKG)/bin/glib-compile-resources \
  GLIB_MKENUMS=$(STAGING_DIR_HOSTPKG)/bin/glib-mkenums \
  GLIB_GENMARSHAL=$(STAGING_DIR_HOSTPKG)/bin/glib-genmarshal

CONFIGURE_ARGS += \
  --prefix=/usr

define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/include \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/include \
	  $(1)/usr/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/{pkgconfig,*.so*} \
	  $(1)/usr/lib/
endef

define Package/atk/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/*.so* \
	  $(1)/usr/lib/
endef

$(eval $(call BuildPackage,atk))
