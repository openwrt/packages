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
PKG_VERSION:=4.1.7
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/zeromq/zeromq4-1/releases/download/v$(PKG_VERSION)
PKG_HASH:=31c383cfcd3be1dc8a66e448c403029e793687e70473b89c4cc0bd626e7da299
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Dirk Chang <dirk@kooiot.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENCE.txt
PKG_CPE_ID:=cpe:/a:zeromq:libzmq

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_REMOVE_FILES:=autogen.sh acinclude.m4 aclocal.m4

include $(INCLUDE_DIR)/package.mk

define Package/libzmq/default
  TITLE:=ZeroMQ - Message Queue engine
  URL:=http://www.zeromq.org/
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libuuid +libpthread +librt +libstdcpp
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
	--enable-shared \
	--with-pic \
	--with-relaxed \
	--without-documentation

ifeq ($(BUILD_VARIANT),curve)
  CONFIGURE_ARGS+= --with-libsodium
else
  CONFIGURE_ARGS+= --without-libsodium
endif

TARGET_CXXFLAGS += -Wno-error=cpp

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
