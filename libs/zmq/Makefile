# 
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# This Makefile for ZeroMQ
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zeromq
PKG_VERSION:=4.1.1
PKG_RELEASE:=1
PKG_MAINTAINER:=Dirk Chang <dirk@kooiot.com>
PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=LICENCE.txt

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:= http://download.zeromq.org
PKG_MD5SUM:=73c39f5eb01b9d7eaf74a5d899f1d03d

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=libuuid

PKG_FIXUP:=autoreconf

PKG_INSTALL:=1


include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/libzmq
  TITLE:=ZeroMQ - Message Queue engine
  URL:=http://www.zeromq.org/
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libuuid +libpthread +librt +PACKAGE_libsodium:libsodium $(CXX_DEPENDS)
  MENU:=1
endef

define Package/libzmq/config
 config LIBZMQ_CURVEZMQ
	bool "Include support for CurveZMQ security"
	depends on PACKAGE_libzmq
	default y
	select PACKAGE_libsodium
endef

define Package/libzmq/description
 This package contains the ZeroMQ messaging engine shared library.
 CurveZMQ security protocols are optional using libsodium.
endef

# add extra configure flags here
CONFIGURE_ARGS += \
	--enable-static \
	--enable-shared

ifneq ($(CONFIG_PACKAGE_libsodium),)
  CONFIGURE_ARGS+= --with-libsodium
else
  CONFIGURE_ARGS+= --without-libsodium
endif

# add make variable overrides here
MAKE_FLAGS +=

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/zmq.h $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/zmq_utils.h $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzmq.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libzmq.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libzmq/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzmq.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libzmq))
