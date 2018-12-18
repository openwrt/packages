#
# Copyright (C) 2017 Steven Hessing
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libyaml-cpp
PKG_VERSION:=0.6.2
PKG_RELEASE:=2

PKG_SOURCE:=yaml-cpp-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/jbeder/yaml-cpp/tar.gz/yaml-cpp-$(PKG_VERSION)?
PKG_HASH:=e4d8560e163c3d875fd5d9e5542b5fd5bec810febdcba61481fe5fc4e6b1fd05

PKG_MAINTAINER:= Steven Hessing <steven.hessing@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:yaml-cpp_project:yaml-cpp

PKG_BUILD_DIR:=$(BUILD_DIR)/yaml-cpp-yaml-cpp-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

CMAKE_INSTALL:=1
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
CMAKE_OPTIONS += -DBUILD_SHARED_LIBS=ON
#CMAKE_OPTIONS += -DBUILD_SHARED_LIBS=OFF
CMAKE_OPTIONS += -DYAML_CPP_BUILD_TESTS=OFF
CMAKE_OPTIONS += -DYAML_CPP_BUILD_TOOLS=OFF


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
	#$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libyaml-cpp.so.0.6 $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libyaml-cpp.so.?.? $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libyaml-cpp))
