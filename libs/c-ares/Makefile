#
# Copyright (C) 2009-2010 OpenWrt.org
# Copyright (C) 2009 Jakob Pfeiffer
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=c-ares
PKG_VERSION:=1.27.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://c-ares.org/download
PKG_HASH:=0a72be66959955c43e2af2fbd03418e82a2bd5464604ec9a62147e37aceb420b

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md
PKG_CPE_ID:=cpe:/a:c-ares_project:c-ares

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libcares
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for asyncronous DNS Requests (including name resolves)
  URL:=https://c-ares.org/
  MAINTAINER:=Karl Palsson <karlp@etactica.com>
endef

define Package/libcares/description
  c-ares is a C library for asynchronous DNS requests (including name resolves)

C89 compatibility, MIT licensed, builds for and runs on POSIX, Windows,
Netware, Android and many more operating systems.

endef

CMAKE_OPTIONS += \
	-DCARES_STATIC_PIC=ON \
	-DCARES_BUILD_TOOLS=OFF

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) 's,/usr/bin,$$$${prefix}/lib,g' $(1)/usr/lib/pkgconfig/libcares.pc
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/libcares.pc
	$(SED) 's,/usr/lib,$$$${prefix}/lib,g' $(1)/usr/lib/pkgconfig/libcares.pc
endef

define Package/libcares/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcares.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libcares))
