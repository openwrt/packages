#
# Copyright (C) 2017 Steven Hessing
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libyaml-cpp
PKG_VERSION:=0.8.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/jbeder/yaml-cpp
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=b81c7d39efa379a52c4cd7a6ee00e21b546e26284a44aa6d4b836e339c655803

PKG_MAINTAINER:= Steven Hessing <steven.hessing@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:yaml-cpp_project:yaml-cpp

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libyaml-cpp
  SECTION:=development
  CATEGORY:=Libraries
  TITLE:=libyaml-cpp
  URL:=https://github.com/jbeder/yaml-cpp
  DEPENDS:=+libstdcpp
  ABI_VERSION:=0.8
endef

define Package/libyaml-cpp/description
  yaml-cpp is a YAML parser and emitter in C++ matching the YAML 1.2 spec.
endef

CMAKE_OPTIONS += \
	-DYAML_BUILD_SHARED_LIBS=ON \
	-DYAML_CPP_BUILD_TESTS=OFF \
	-DYAML_CPP_BUILD_TOOLS=OFF

define Package/libyaml-cpp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libyaml-cpp.so.$(ABI_VERSION) $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libyaml-cpp))
