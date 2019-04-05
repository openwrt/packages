# 
# Copyright (C) 2014, 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=yajl
PKG_VERSION:=2.1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Charles Southerland <charlie@stuphlabs.com>
PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=COPYING
PKG_REV:=66cb08ca2ad8581080b626a75dfca266a890afb2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_URL:=https://github.com/lloyd/yajl.git
PKG_SOURCE_PROTO:=git

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/yajl
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Yet Another JSON Library
  URL:=http://lloyd.github.io/yajl
endef

define Package/yajl/description
  Yet Another JSON Library. YAJL is a small event-driven (SAX-style)
JSON parser written in ANSI C, and a small validating JSON generator.
YAJL is released under the ISC license.

  YAJL was created by Lloyd Hilaiel.
endef

PKG_INSTALL:=1

CMAKE_OPTIONS += \
	-DCMAKE_BUILD_TYPE:String="Release" 

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/yajl $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libyajl.so* $(1)/usr/lib/
endef

define Package/yajl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libyajl.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,yajl))
