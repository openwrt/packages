# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libevdev
PKG_VERSION:=1.10.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.freedesktop.org/software/libevdev/
PKG_HASH:=0330fe8357ece915db9366c1b9a6648941aea6f724b73ad6e71401127aa08932

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
	$(INSTALL_DIR) $(1)/usr/include/libevdev-1.0/libevdev
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libevdev-1.0/libevdev/*.h $(1)/usr/include/libevdev-1.0/libevdev
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libevdev.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libevdev.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libevdev/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libevdev.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libevdev))
