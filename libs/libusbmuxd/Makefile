#
# Copyright (C) 2012-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libusbmuxd
PKG_VERSION:=1.1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Lukasz Baj <l.baj@radytek.com>
PKG_LICENSE:=LGPL-2.1+
PKG_LICENSE_FILES:=COPYING.LGPLv2.1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/libimobiledevice/libusbmuxd.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=f347085157006523622b0a7160be68d14f037c00
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libusbmuxd/Default
  TITLE:=USB multiplexing daemon
  URL:=http://www.libimobiledevice.org/
endef

define Package/libusbmuxd/Default/description
  This daemon is in charge of multiplexing connections over USB to an iPhone or
  iPod touch. To users, it means you can sync your music, contacts, photos, etc.
  over USB. To developers, it means you can connect to any listening localhost
  socket on the device. usbmuxd is not used for tethering data transfer, which
  uses a dedicated USB interface as a virtual network device.
endef

define Package/libusbmuxd
  $(call Package/libusbmuxd/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= library
  DEPENDS:=+libplist +libpthread +libxml2 +zlib
endef

define Package/libusbmuxd/description
  $(call Package/libusbmuxd/Default/description)
  This package contains the libusbmuxd shared library.
endef

define Package/libusbmuxd-utils
  $(call Package/libusbmuxd/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE+= utilies
  DEPENDS:=+libusbmuxd
endef

define Package/libusbmuxd-utils/description
  $(call Package/libusbmuxd/Default/description)
  This package contains the libusbmuxd utilities.
endef

TARGET_CFLAGS += $(FPIC)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libusbmuxd.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libusbmuxd.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libusbmuxd/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libusbmuxd.so.* $(1)/usr/lib/
endef

define Package/libusbmuxd-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/iproxy $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libusbmuxd))
$(eval $(call BuildPackage,libusbmuxd-utils))
