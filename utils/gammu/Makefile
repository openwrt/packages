#
# Copyright (C) 2006-2015 OpenWrt.org
#		2014-2015 Vitaly Protsko
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gammu
PKG_VERSION:=1.34.0
PKG_RELEASE:=3

PKG_SOURCE_URL:=http://dl.cihar.com/gammu/releases/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MD5SUM:=5bc2508389d9b291ca0b8d4f210d0012
PKG_MAINTAINER:=Vitaly Protsko <villy@sft.ru>
PKG_LICENCE:=GPL-2.0

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/gammu
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=Cell phone/modem SMS and control tool
	URL:=http://dl.cihar.com/gammu/releases/
	DEPENDS:=+libpthread +libcurl +glib2 $(ICONV_DEPENDS) $(INTL_DEPENDS)
	DEPENDS+=+PACKAGE_python:python +PACKAGE_bluez-libs:bluez-libs
	DEPENDS+=+PACKAGE_libmysqlclient:libmysqlclient +PACKAGE_unixodbc:unixodbc +PACKAGE_libpq:libpq
	DEPENDS+=+PACKAGE_libusb-1.0:libusb-1.0
endef

CMAKE_OPTIONS += -DWITH_LibDBI:BOOL=OFF


define Build/InstallDev
	mkdir -p $(1)/usr/include
	$(CP) -r $(PKG_INSTALL_DIR)/usr/include/gammu $(1)/usr/include/
	mkdir -p $(1)/usr/lib
	$(CP)    $(PKG_INSTALL_DIR)/usr/lib$(LIB_SUFFIX)/lib{Gammu*,gsmsd*} $(1)/usr/lib/
endef

define Package/gammu/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gammu $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gammu-{smsd,smsd-inject,smsd-monitor} $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib$(LIB_SUFFIX)/lib{Gammu*,gsmsd*} $(1)/usr/lib
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/gammu $(1)/etc/config/gammu
	$(INSTALL_BIN) ./files/gammu.init $(1)/etc/init.d/gammu
endef

define Package/gammu/conffiles
/etc/config/gammu
endef

$(eval $(call BuildPackage,gammu))
