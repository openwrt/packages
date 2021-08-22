include $(TOPDIR)/rules.mk

PKG_NAME:=wayland-protocols
PKG_VERSION:=1.21
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://wayland.freedesktop.org/releases/
PKG_HASH:=b99945842d8be18817c26ee77dafa157883af89268e15f4a5a1a1ff3ffa4cde5

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

PKG_BUILD_DEPENDS:=wayland

include $(INCLUDE_DIR)/package.mk
include ../../devel/meson/meson.mk

MESON_ARGS += \
	-Dtests=false

define Package/wayland-protocols
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Video
  TITLE:=wayland-protocols
  URL:=https://wayland.freedesktop.org/
  PKGARCH:=all
endef

define Package/wayland-protocols/description
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/share/wayland-protocols
	$(CP) $(PKG_INSTALL_DIR)/usr/share/wayland-protocols/* $(1)/usr/share/wayland-protocols
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/share/pkgconfig/*.pc $(1)/usr/lib/pkgconfig
endef

define Package/wayland-protocols/install
	$(INSTALL_DIR) $(1)/usr/share/wayland-protocols
	$(CP) $(PKG_INSTALL_DIR)/usr/share/wayland-protocols/* $(1)/usr/share/wayland-protocols
endef

$(eval $(call BuildPackage,wayland-protocols))
