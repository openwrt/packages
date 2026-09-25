include $(TOPDIR)/rules.mk

PKG_NAME:=libgudev
PKG_VERSION:=238
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/$(PKG_NAME)/$(PKG_VERSION)
PKG_HASH:=61266ab1afc9d73dbc60a8b2af73e99d2fdff47d99544d085760e4fa667b5dd1

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=glib2/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk
include $(INCLUDE_DIR)/nls.mk

define Package/libgudev
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=GObject udev library
  URL:=https://gitlab.gnome.org/GNOME/libgudev
  DEPENDS:=+glib2 +libudev
endef

define Package/libgudev/description
 This is libgudev, a library providing GObject bindings for libudev.
 It used to be part of udev, then merged into systemd. It's now a project
 on its own.
endef

MESON_ARGS += \
	-Dtests=disabled \
	-Dintrospection=disabled \
	-Dvapi=disabled \
	-Dgtk_doc=false

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/gudev-1.0/gudev
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gudev-1.0/gudev/*.h $(1)/usr/include/gudev-1.0/gudev
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig
endef

define Package/libgudev/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libgudev))
