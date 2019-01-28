#
# Copyright (C) 2019 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=jsoncpp
PKG_VERSION:=1.8.4
PKG_RELEASE:=1
PKG_MAINTAINER:=
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_URL:=https://codeload.github.com/open-source-parsers/jsoncpp/tar.gz/$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=c49deac9e0933bcb7044f08516861a2d560988540b23de2ac1ad443b219afdb6

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/jsoncpp
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=jsoncpp
  URL:=https://github.com/open-source-parsers/jsoncpp
  DEPENDS:=+libstdcpp
endef

define Package/jsoncpp/description
  JsonCpp is a C++ library that allows manipulating
  JSON values, including serialization and
  deserialization to and from strings. It can also
  preserve existing comment in
  unserialization/serialization steps, making it a
  convenient format to store user input files.
endef

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS:BOOL=ON \
	-DBUILD_STATIC_LIBS:BOOL=OFF \
	-DJSONCPP_WITH_TESTS:BOOL=OFF

define Package/jsoncpp/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjsoncpp.so* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/json $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjsoncpp.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/jsoncpp.pc $(1)/usr/lib/pkgconfig/
endef

$(eval $(call BuildPackage,jsoncpp))
