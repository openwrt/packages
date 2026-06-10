#
# Copyright (C) 2019 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=jsoncpp
PKG_VERSION:=1.9.7
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/open-source-parsers/jsoncpp/tar.gz/$(PKG_VERSION)?
PKG_HASH:=830bf352d822d8558e9d0eb19d640d2e38536b4b6699c30a4488da09d5b1df18

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:jsoncpp_project:jsoncpp

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

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

MESON_ARGS += \
	-Db_lto=true \
	-Dtests=false \
	-Dcpp_std=c++17

TARGET_LDFLAGS += -Wl,--gc-sections

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/json $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjsoncpp.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/jsoncpp.pc $(1)/usr/lib/pkgconfig/
endef

define Package/jsoncpp/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjsoncpp.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,jsoncpp))
