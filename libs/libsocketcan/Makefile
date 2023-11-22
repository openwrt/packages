#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libsocketcan
PKG_VERSION:=0.0.12
PKG_RELEASE=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://www.pengutronix.de/software/libsocketcan/download/
PKG_HASH:=be8280124707701935e6294d366e2474158b758fa4b2e3cae571d5b256d2fe34

PKG_MAINTAINER:=Yegor Yefremov <yegorslists@googlemail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libsocketcan
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library to control SocketCAN interfaces
  URL:=https://git.pengutronix.de/cgit/tools/libsocketcan
endef

define Package/libsocketcan/description
  This userspace library allows one to do common configure/control tasks
on a SocketCAN interface.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/can_netlink.h $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libsocketcan.h $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsocketcan.{a,so*} $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libsocketcan.pc $(1)/usr/lib/pkgconfig
endef

define Package/libsocketcan/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsocketcan.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libsocketcan))
