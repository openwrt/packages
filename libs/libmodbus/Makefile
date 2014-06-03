#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmodbus
PKG_VERSION:=3.0.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://libmodbus.org/releases
PKG_MD5SUM:=c80f88b6ca19cabc4ceffc195ca07771

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libmodbus
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=http://www.libmodbus.org
  TITLE:=libmodbus
  MAINTAINER:=Michael Heimpold <mhei@heimpold.de>
endef

define Package/libmodbus/description
A Modbus library for Linux, Mac OS X, FreeBSD, QNX and Win32
endef

TARGET_CFLAGS += $(FPIC)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/modbus $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmodbus.{so*,la} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libmodbus.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libmodbus/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmodbus.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libmodbus))
