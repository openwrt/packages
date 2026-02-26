#
# Copyright (C) 2026 Wei-Ting Yang <williamatcg@gmail.com>
#
# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=thrift
PKG_VERSION:=0.22.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@APACHE/$(PKG_NAME)/$(PKG_VERSION)
PKG_HASH:=794a0e455787960d9f27ab92c38e34da27e8deeda7a5db0e59dc64a00df8a1e5

PKG_MAINTAINER:=Wei-Ting Yang <williamatcg@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:apache:thrift

PKG_BUILD_DEPENDS:=boost
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/thrift
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Apache Thrift
  URL:=https://thrift.apache.org/
  DEPENDS:=+libstdcpp
endef

define Package/thrift/description
Thrift is a lightweight, language-independent software stack for point-to-point
RPC implementation. Thrift provides clean abstractions and implementations for
data transport, data serialization, and application level processing. The code
generation system takes a simple definition language as input and generates code
across programming languages that uses the abstracted stack to build
interoperable RPC clients and servers.

This package provides the Apache Thrift C++ library.
endef

CMAKE_OPTIONS += \
	-DBUILD_COMPILER=OFF \
	-DBUILD_LIBRARIES=ON \
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_TESTING=OFF \
	-DBUILD_TUTORIALS=OFF

# Language libraries
CMAKE_OPTIONS += \
	-DWITH_AS3=OFF \
	-DWITH_C_GLIB=OFF \
	-DWITH_CPP=ON \
	-DWITH_JAVA=OFF \
	-DWITH_JAVASCRIPT=OFF \
	-DWITH_NODEJS=OFF \
	-DWITH_PYTHON=OFF

# Additional supports
CMAKE_OPTIONS += \
	-DWITH_LIBEVENT=OFF \
	-DWITH_OPENSSL=OFF \
	-DWITH_QT5=OFF \
	-DWITH_ZLIB=OFF

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/thrift $(1)/usr/include

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libthrift.so* $(1)/usr/lib

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/thrift.pc $(1)/usr/lib/pkgconfig
endef

define Package/thrift/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libthrift.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,thrift))
