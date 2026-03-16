include $(TOPDIR)/rules.mk

PKG_NAME:=xdg-dbus-proxy
PKG_VERSION:=0.1.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/flatpak/$(PKG_NAME)/releases/download/$(PKG_VERSION)
PKG_HASH:=131bf59fce7c7ee7ecbc5d9106d6750f4f597bfe609966573240f7e4952973a1

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=LGPLv2-or-later

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk
include $(INCLUDE_DIR)/nls.mk

MESON_ARGS += \
	-Dinstalled_tests=false \
	-Dman=disabled \
	-Dtests=false

define Package/xdg-dbus-proxy
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=xdg-dbus-proxy
  URL:=https://github.com/containers/xdg-dbus-proxy
  DEPENDS:=+glib2
endef

define Package/xdg-dbus-proxy/description
 xdg-dbus-proxy is a filtering proxy for D-Bus connections.
endef

define Package/xdg-dbus-proxy/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/xdg-dbus-proxy $(1)/usr/bin
endef

$(eval $(call BuildPackage,xdg-dbus-proxy))
