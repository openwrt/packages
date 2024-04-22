#
# Copyright (C) 2012-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=usbmuxd
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/libimobiledevice/usbmuxd.git
PKG_SOURCE_DATE:=2023-10-11
PKG_SOURCE_VERSION:=360619c5f721f93f0b9d8af1a2df0b926fbcf281
PKG_MIRROR_HASH:=e674ee39abbbae6dea7364be8b8287db2e333d033c226d4b2ed95f2e61a78576

PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING.GPLv2
PKG_CPE_ID:=cpe:/a:libimobiledevice:usbmuxd

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/usbmuxd
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=libimobiledevice
  TITLE:=USB multiplexing daemon
  URL:=https://www.libimobiledevice.org/
  DEPENDS:=+libusb-1.0 +libusbmuxd +libopenssl +libimobiledevice +usbutils
endef

define Package/usbmuxd/description
  This daemon is in charge of multiplexing connections over USB to an iPhone or
  iPod touch. To users, it means you can sync your music, contacts, photos, etc.
  over USB. To developers, it means you can connect to any listening localhost
  socket on the device. usbmuxd is not used for tethering data transfer, which
  uses a dedicated USB interface as a virtual network device.
endef

define Package/usbmuxd/conffiles
/etc/lockdown
/etc/lockdown/SystemConfiguration.plist
endef

CONFIGURE_ARGS += \
	--with-systemd \
	PACKAGE_VERSION=$(PKG_VERSION)

define Package/usbmuxd/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/usb
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/usbmuxd.hotplug $(1)/etc/hotplug.d/usb/40-usbmuxd
	$(INSTALL_BIN) ./files/usbmuxd.init $(1)/etc/init.d/usbmuxd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/usbmuxd $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,usbmuxd))
