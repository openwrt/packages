# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libinput
PKG_VERSION:=1.19.2
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://www.freedesktop.org/software/libinput
PKG_HASH:=0fc39f0af3ee1a77c60c34bc45391a4d0879169f7c0f7bbbeb5eef590b98b883

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=meson/host

include $(INCLUDE_DIR)/package.mk
include ../../devel/meson/meson.mk

define Package/libinput
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=a library to handle input devices
  URL:=http://freedesktop.org/wiki/Software/libinput/
  DEPENDS:=+libevdev +mtdev +libudev
endef

define Package/libinput/description
  libinput is a library to handle input devices in Wayland compositors
  and to provide a generic X.Org input driver. It provides device
  detection, device handling, input device event processing and
  abstraction so minimize the amount of custom input code compositors
  need to provide the common set of functionality that users expect.
endef

MESON_ARGS += \
	-Depoll-dir=no \
	-Dlibwacom=false \
	-Ddebug-gui=false \
	-Dtests=false \
	-Dinstall-tests=false \
	-Ddocumentation=false \
	-Dcoverity=false \
	-Dzshcompletiondir=no

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libinput.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libinput.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libinput.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libinput/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/{udev,libinput.so.*} $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/libexec/libinput
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/libexec/libinput/* $(1)/usr/libexec/libinput
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/libinput $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/share/libinput
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/libinput/* $(1)/usr/share/libinput
endef

$(eval $(call BuildPackage,libinput))
