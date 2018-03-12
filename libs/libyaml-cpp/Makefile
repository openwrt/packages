#
# Copyright (C) 2017 Steven Hessing
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libyaml-cpp
PKG_RELEASE:=1

PKG_MAINTAINER:= Steven Hessing <steven.hessing@gmail.com>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/jbeder/yaml-cpp/
PKG_SOURCE_DATA:=2017-11-01
PKG_SOURCE_VERSION:=beb44b872c07c74556314e730c6f20a00b32e8e5
PKG_MIRROR_HASH:=3ddb1f5a6c564f33fd164c0300df8048c689c319964a08386d869637a0f5c8e2

PKG_SOURCE_SUBDIR:=yaml-cpp

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_BUILD_PARALLEL:=1

CMAKE_INSTALL:=1
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
CMAKE_OPTIONS += -DBUILD_SHARED_LIBS=ON
#CMAKE_OPTIONS += -DBUILD_SHARED_LIBS=OFF

define Package/libyaml-cpp
	SECTION:=development
	CATEGORY:=Libraries
	TITLE:=libyaml-cpp 
	URL:=https://github.com/jbeder/yaml-cpp
	DEPENDS:=+libstdcpp
endef

define Package/libyaml-cpp/description
yaml-cpp is a YAML parser and emitter in C++ matching the YAML 1.2 spec.
endef

define Package/libyaml-cpp/install
	$(INSTALL_DIR) $(1)/usr/lib
	#$(INSTALL_DATA) $(PKG_BUILD_DIR)/libyaml-cpp.so.0.5.3 $(1)/usr/lib/
	#$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libyaml-cpp.so.0.5.3 $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libyaml-cpp.so.0.5 $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libyaml-cpp))
