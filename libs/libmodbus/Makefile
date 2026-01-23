#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmodbus
PKG_VERSION:=3.1.11
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/stephane/libmodbus/releases/download/v$(PKG_VERSION)/
PKG_HASH:=15b4b2e0f68122c2da9b195de5c330489a9c97d40b4a95d2822378dc14d780e7

PKG_MAINTAINER:=Michael Heimpold <mhei@heimpold.de>

PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING.LESSER
PKG_CPE_ID:=cpe:/a:libmodbus:libmodbus

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libmodbus
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=http://www.libmodbus.org
  TITLE:=libmodbus
endef

define Package/libmodbus/description
  A Modbus library for Linux, Mac OS X, FreeBSD, QNX and Win32.
endef

CONFIGURE_ARGS += --disable-tests
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
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmodbus.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libmodbus))
