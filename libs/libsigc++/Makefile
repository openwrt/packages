#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libsigc++
PKG_VERSION:=2.10.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/libsigc++/2.10
PKG_HASH:=b1ca0253379596f9c19f070c83d362b12dfd39c0a3ea1dd813e8e21c1a097a98

PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_LICENSE:=LGPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libsigcxx
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=typesafe callback system for standard C++
  URL:=https://libsigcplusplus.github.io/libsigcplusplus/
  DEPENDS:=+libstdcpp
endef

define Package/libsigcxx/description
 It allows you to define signals and to connect those signals to any
 callback function, either global or a member function, regardless of
 whether it is static or virtual.
endef

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--disable-benchmark \
	--disable-documentation \
	--disable-deprecated-api \
	--disable-warnings \
	--without-boost

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/sigc++-2.0 $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsigc-2.0.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/sigc++-2.0 $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/sigc++-2.0.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libsigcxx/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsigc-2.0.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libsigcxx))
