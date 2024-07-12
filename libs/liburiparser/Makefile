#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=liburiparser
PKG_VERSION:=0.9.8
PKG_RELEASE:=1

PKG_SOURCE:=uriparser-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/uriparser/uriparser/releases/download/uriparser-$(PKG_VERSION)
PKG_HASH:=4cd0e4f93b477272fabceeb0202f269169fe6ec3044e10fac6acbcdf354bb080
PKG_BUILD_DIR:=$(BUILD_DIR)/uriparser-$(PKG_VERSION)

PKG_MAINTAINER:=Weijia Song <songweijia@gmail.com> & Sebastian Pipping <sebastian@pipping.org>
PKG_LICENSE:=New BSD license
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:uriparser:uriparser

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/liburiparser
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=RFC 3986 URI parsing library
  URL:=https://uriparser.github.io/
endef

define Package/liburiparser/description
 uriparser is a strictly RFC 3986 compliant URI parsing and handling library written in C89 ("ANSI C"). 
endef

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS:BOOL=ON \
	-DURIPARSER_BUILD_DOCS:BOOL=OFF \
	-DURIPARSER_BUILD_TESTS:BOOL=OFF \
	-DURIPARSER_BUILD_TOOLS:BOOL=OFF \
	-DURIPARSER_BUILD_CHAR:BOOL=ON \
	-DURIPARSER_BUILD_WCHAR_T:BOOL=ON \
	-DURIPARSER_ENABLE_INSTALL:BOOL=ON \
	-DURIPARSER_WARNINGS_AS_ERRORS:BOOL=OFF

define Package/liburiparser/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/liburiparser.so* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,liburiparser))
