#
# Copyright (C) 2010 Telldus Technologies AB
#
# This is free software, licensed under the GNU General Public License v2.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=telldus-core
PKG_VERSION:=2.1.2
PKG_RELEASE:=8

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://download.telldus.com/TellStick/Software/telldus-core/
PKG_HASH:=a20f6c74814afc23312d2c93ebbb37fdea9deaaee05ae7b6a6275e11e4662014

PKG_MAINTAINER:=Peter Liedholm <PeterFromSwe884@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1
PKG_BUILD_DEPENDS:=argp-standalone

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Download/argp-cmake
	URL:=@GITHUB/alehaa/CMake-argp/e7e77e68d062708edf055f944d3094b0ce0b11b8/cmake
	FILE:=Findargp.cmake
	HASH:=b74e961260d17bc9af868be59053e50739dc94e06cbe73e3fced414a070a29fd
endef

define Build/Prepare
	$(eval $(call Download,argp-cmake))
	$(Build/Prepare/Default)
	$(CP) $(DL_DIR)/Findargp.cmake $(PKG_BUILD_DIR)/cmake/
endef

define Package/telldus-core
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=Telldus TellStick USB interface
	URL:=https://telldus.com
	DEPENDS:=+confuse +libftdi +libstdcpp
endef

define Package/telldus-core/description
	Telldus driver for USB-based 433 MHz RF transceiver for home automation.
	MUST be built with full language support, (don't know how to DEPEND that)
endef

define Package/telldus-core/conffiles
/etc/tellstick.conf
endef

CMAKE_OPTIONS += \
	-DBUILD_LIBTELLDUS-CORE=1 \
	-DBUILD_TDTOOL=1 \
	-DGENERATE_MAN=0

define Package/telldus-core/install
	$(INSTALL_DIR)  $(1)/usr/bin
	$(INSTALL_BIN)  $(PKG_INSTALL_DIR)/usr/bin/tdtool $(1)/usr/bin
	$(INSTALL_DIR)  $(1)/usr/sbin
	$(INSTALL_BIN)  $(PKG_INSTALL_DIR)/usr/sbin/telldusd $(1)/usr/sbin
	$(INSTALL_BIN)  $(PKG_INSTALL_DIR)/usr/sbin/tdadmin $(1)/usr/sbin
	$(INSTALL_DIR)  $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libtelldus* $(1)/usr/lib
	$(INSTALL_DIR)  $(1)/etc/config
	$(INSTALL_CONF) ./files/tellstick.conf $(1)/etc
	$(INSTALL_DIR)  $(1)/etc/init.d
	$(INSTALL_BIN)  ./files/telldusd $(1)/etc/init.d
endef

$(eval $(call BuildPackage,telldus-core))
