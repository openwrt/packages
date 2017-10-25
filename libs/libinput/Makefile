# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libinput
PKG_VERSION:=1.7.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://www.freedesktop.org/software/libinput/
PKG_HASH:=096d612d2711f0caa2de544976ff3729e6233511ab373808644cc2dd5affcb1d

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS+= -std=gnu99

CONFIGURE_ARGS += --disable-libwacom --disable-tests --disable-documentation

define Package/libinput
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=a library to handle input devices
  URL:=http://freedesktop.org/wiki/Software/libinput/
  DEPENDS:=+libevdev +mtdev +libudev-fbsd
endef

define Package/libinput/description
  libinput is a library to handle input devices in Wayland compositors
  and to provide a generic X.Org input driver. It provides device
  detection, device handling, input device event processing and
  abstraction so minimize the amount of custom input code compositors
  need to provide the common set of functionality that users expect.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{la,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
endef

define Package/libinput/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/{udev,*.so*} $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin
endef

$(eval $(call BuildPackage,libinput))
