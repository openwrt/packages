# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libevdev
PKG_VERSION:=1.9.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.freedesktop.org/software/libevdev/
PKG_HASH:=e7e18a64264f2dea19b6c50a481f8c062529d42919ccda0bc861495bce28eb9e

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=meson/host

include $(INCLUDE_DIR)/package.mk
include ../../devel/meson/meson.mk

define Package/libevdev
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=a wrapper library for evdev devices
  URL:=https://www.freedesktop.org/wiki/Software/libevdev/
endef

define Package/libevdev/description
  libevdev is a wrapper library for evdev devices. it moves the common
  tasks when dealing with evdev devices into a library and provides a
  library interface to the callers, thus avoiding erroneous ioctls, etc.

  The eventual goal is that libevdev wraps all ioctls available to
  evdev devices, thus making direct access unnecessary.
endef

MESON_ARGS += \
	-Dtests=disabled \
	-Ddocumentation=disabled \
	-Dcoverity=false

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
endef

define Package/libevdev/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libevdev))
