include $(TOPDIR)/rules.mk

PKG_NAME:=wayland-utils
PKG_VERSION:=1.0.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://wayland.freedesktop.org/releases/
PKG_HASH:=64fecc4c58e87ae9b302901abe10c2e8af69c7503c221a96ecd0700e0aa268c0

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=meson/host wayland/host

include $(INCLUDE_DIR)/package.mk
include ../../devel/meson/meson.mk

define Package/wayland-info
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Video
  TITLE:=wayland-utils
  URL:=https://wayland.freedesktop.org/
  DEPENDS:=+libwayland +wayland-protocols
endef

define Package/wayland-info/description
endef

MESON_ARGS += \
	-Dscanner_bin="$(STAGING_DIR_HOSTPKG)/bin/wayland-scanner"

define Package/wayland-info/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/wayland-info $(1)/usr/bin
endef

$(eval $(call BuildPackage,wayland-info))
