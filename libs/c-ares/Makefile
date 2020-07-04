#
# Copyright (C) 2009-2010 OpenWrt.org
# Copyright (C) 2009 Jakob Pfeiffer
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=c-ares
PKG_VERSION:=1.16.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://c-ares.haxx.se/download
PKG_HASH:=d08312d0ecc3bd48eee0a4cc0d2137c9f194e0a28de2028928c0f6cae85f86ce

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md
PKG_CPE_ID:=cpe:/a:c-ares_project:c-ares

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libcares
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for asyncronous DNS Requests (including name resolves)
  URL:=http://c-ares.haxx.se/
  MAINTAINER:=Karl Palsson <karlp@etactica.com>
endef

define Package/libcares/description
  c-ares is a C library for asynchronous DNS requests (including name resolves)

C89 compatibility, MIT licensed, builds for and runs on POSIX, Windows,
Netware, Android and many more operating systems.

endef

CMAKE_OPTIONS += \
	-DCARES_STATIC=OFF \
	-DCARES_SHARED=ON \
	-DCARES_STATIC_PIC=ON \
	-DCARES_BUILD_TESTS=OFF \
	-DCARES_BUILD_TOOLS=OFF

define Package/libcares/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcares.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libcares))
