# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libinput
PKG_VERSION:=1.28.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://gitlab.freedesktop.org/$(PKG_NAME)/$(PKG_NAME)/-/archive/$(PKG_VERSION)
PKG_HASH:=a13f8c9a7d93df3c85c66afd135f0296701d8d32f911991b7aa4273fdd6a42a3

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:freedesktop:libinput

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libinput
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=a library to handle input devices
  URL:=https://freedesktop.org/wiki/Software/libinput/
  DEPENDS:=+libevdev +mtdev +libudev +libwacom
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
	-Dlibwacom=true \
	-Ddebug-gui=false \
	-Dtests=false \
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
