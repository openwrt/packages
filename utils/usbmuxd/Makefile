#
# Copyright (C) 2012-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=usbmuxd
PKG_VERSION:=1.1.1
PKG_RELEASE:=4
PKG_SOURCE_PROTO:=git

PKG_MAINTAINER:=Lukasz Baj <l.baj@radytek.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING.GPLv2

PKG_SOURCE_URL:=https://github.com/libimobiledevice/usbmuxd.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=35e5d48f29ae03b2b9686109e4ed9ab8b9677ce8
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=7c0d8ea230570344fbc0183c0171689c74baf3d75fff33bbdfca2d1775a4d62d

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

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

TARGET_CFLAGS += $(FPIC)

define Package/usbmuxd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/usbmuxd $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,usbmuxd))
