#
# Copyright (C) 2012-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=usbmuxd
PKG_SOURCE_DATE:=2019-03-04
PKG_SOURCE_VERSION:=b1b0bf390363fa36aff1bc09443ff751943b9c34
PKG_RELEASE:=1

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING.GPLv2
PKG_CPE_ID:=cpe:/a:nikias_bassen:usbmuxd

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL=https://codeload.github.com/libimobiledevice/usbmuxd/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=ca4275dbc21e8d9c926e65943b605ea5a6112d30eb3f9e655d3983da87ac6798
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/usbmuxd
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=USB multiplexing daemon
  URL:=http://www.libimobiledevice.org/
  DEPENDS:=+librt +libusb-1.0 +libusbmuxd +libopenssl +libimobiledevice
endef

define Package/usbmuxd/description
  This daemon is in charge of multiplexing connections over USB to an iPhone or
  iPod touch. To users, it means you can sync your music, contacts, photos, etc.
  over USB. To developers, it means you can connect to any listening localhost
  socket on the device. usbmuxd is not used for tethering data transfer, which
  uses a dedicated USB interface as a virtual network device.
endef

CONFIGURE_ARGS += --without-systemd

define Package/usbmuxd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/usbmuxd $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,usbmuxd))
