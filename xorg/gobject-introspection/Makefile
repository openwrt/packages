# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=gobject-introspection
PKG_VERSION:=1.58.3
_PKG_VERSION:=1.58
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://download.gnome.org/sources/$(PKG_NAME)/$(_PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_HASH:=025b632bbd944dcf11fc50d19a0ca086b83baf92b3e34936d008180d28cdc3c8

#PKG_BUILD_DEPENDS:=gobject-introspection/host python/host
#PKG_BUILD_PARALLEL:=1
#PKG_INSTALL:=1
HOST_BUILD_PARALLEL:=1
PKG_HOST_ONLY:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/gobject-introspection
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+glib2 +cairo
  TITLE:=Introspection system for GObject-based libraries
  URL:=https://wiki.gnome.org/action/show/Projects/GObjectIntrospection
endef

##MAKE_FLAGS+=GI_CROSS_LAUNCHER="$(STAGING_DIR_HOSTPKG)/bin/g-ir-compiler"

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CONFIGURE_ARGS += \
  --prefix=/usr \
  --disable-static \
  --disable-doctool

#HOST_CONFIGURE_ARGS += \
#  --disable-static \
#  --disable-doctool \
#  --with-python=$(STAGING_DIR_HOSTPKG)/bin/python$(PYTHON_VERSION)

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

define Package/gobject-introspection/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/*.so* \
	  $(1)/usr/lib/
endef

$(eval $(call BuildPackage,gobject-introspection))
$(eval $(call HostBuild))
