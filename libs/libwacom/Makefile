# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libwacom
PKG_VERSION:=2.16.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/linuxwacom/$(PKG_NAME)/releases/download/$(PKG_NAME)-$(PKG_VERSION)/
PKG_HASH:=0f9bc90babad92b2c4c6571b53af3aee065f437cce01c06c860599e1a10680aa

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libwacom
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=a tablet description library
  URL:=https://github.com/linuxwacom/libwacom
  DEPENDS:=+glib2 +libevdev +libgudev
endef

define Package/libwacom/description
libwacom is a library to identify graphics tablets and their model-specific
features. It provides easy access to information such as "is this a built-in
on-screen tablet", "what is the size of this model", etc.

The name libwacom is historical - it was originally developed for Wacom devices
only but now supports any graphics tablet from any vendor.
endef

MESON_ARGS += \
	-Ddocumentation=disabled \
	-Dtests=disabled

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/libwacom-1.0/libwacom
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libwacom-1.0/libwacom/*.h \
		$(1)/usr/include/libwacom-1.0/libwacom
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig
endef

define Package/libwacom/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/{udev,*.so*} $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/share/libwacom
	$(CP) $(PKG_INSTALL_DIR)/usr/share/libwacom/* $(1)/usr/share/libwacom
endef

$(eval $(call BuildPackage,libwacom))
