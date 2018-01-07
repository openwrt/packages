# 
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# This Makefile for ZeroMQ
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zeromq
PKG_VERSION:=4.1.4
PKG_RELEASE:=1
PKG_MAINTAINER:=Dirk Chang <dirk@kooiot.com>
PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=LICENCE.txt

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:= https://github.com/zeromq/zeromq4-1/releases/download/v$(PKG_VERSION)/
PKG_HASH:=e99f44fde25c2e4cb84ce440f87ca7d3fe3271c2b8cfbc67d55e4de25e6fe378

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

PKG_FIXUP:=autoreconf

PKG_INSTALL:=1


include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/libzmq/default
  TITLE:=ZeroMQ - Message Queue engine
  URL:=http://www.zeromq.org/
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libuuid +libpthread +librt $(CXX_DEPENDS)
  PROVIDES:=libzmq
endef

define Package/libzmq-nc
  $(call Package/libzmq/default)
  VARIANT:=nc
endef

define Package/libzmq-curve
  $(call Package/libzmq/default)
  VARIANT:=curve
  TITLE+= (CurveZMQ)
  DEPENDS+=+libsodium 
endef

define Package/libzmq-nc/description
 This package contains the ZeroMQ messaging engine shared library.
endef

define Package/libzmq-curve/description
 $(call Package/libzmq-nc/description)
 Includes CurveZMQ security by libsodium.
endef

# add extra configure flags here
CONFIGURE_ARGS += \
	--enable-static \
	--enable-shared

ifeq ($(BUILD_VARIANT),curve)
  CONFIGURE_ARGS+= --with-libsodium
else
  CONFIGURE_ARGS+= --without-libsodium
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/zmq.h $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/zmq_utils.h $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzmq.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libzmq.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libzmq-nc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzmq.so.* $(1)/usr/lib/
endef

Package/libzmq-curve/install=$(Package/libzmq-nc/install)

$(eval $(call BuildPackage,libzmq-nc))
$(eval $(call BuildPackage,libzmq-curve))
