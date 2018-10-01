#
# Copyright (C) 2018 Bruno Randolf (br1@einfach.org)
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cpprestsdk
PKG_VERSION:=2.10.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-git.tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/Microsoft/cpprestsdk
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=4ebbc832e6abaf3a3abd9f70bb9f9556fcd6b6645239c76e84d9201f8f805678

PKG_MAINTAINER:=Bruno Randolf <br1@einfach.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=license.txt

PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=websocketpp

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_INSTALL:=1
CMAKE_SOURCE_DIR:=Release
CMAKE_OPTIONS += -DWERROR:Bool=OFF
CMAKE_OPTIONS += -DBUILD_TESTS:Bool=OFF
CMAKE_OPTIONS += -DBUILD_SAMPLES:Bool=OFF

define Package/cpprestsdk
	SECTION:=libs
	CATEGORY:=Libraries
	DEPENDS:=+zlib +libopenssl +boost +boost-atomic +boost-chrono +boost-date_time +boost-filesystem +boost-random +boost-regex +boost-system +boost-thread
	TITLE:=Microsoft C++ REST SDK
	URL:=https://github.com/Microsoft/cpprestsdk
endef

define Package/cpprestsdk/description
	Microsoft project for cloud-based client-server communication in native
	code using a modern asynchronous C++ API design.
endef

define Package/cpprestsdk/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcpprest.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,cpprestsdk))
