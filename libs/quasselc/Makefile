#
# Copyright (C) 2016 Ben Rosser <rosser.bjr@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=quasselc

# quasselc upstream doesn't release versions (at least, at the moment),
# so use commit date for PKG_VERSION and embed commit hash into PKG_RELEASE.
PKG_VERSION:=2015-04-06
PKG_SOURCE_VERSION:=fcd966966924e3d9af0954db56117e2f48767ea1
PKG_RELEASE:=1.$(PKG_SOURCE_VERSION)

PKG_LICENSE:=GPL-3.0+

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/phhusson/QuasselC
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.bz2

PKG_MAINTAINER:=Ben Rosser <rosser.bjr@gmail.com>

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

MAKE_FLAGS += prefix=$(STAGING_DIR)/usr libdir=$(STAGING_DIR)/usr/lib includedir=$(STAGING_DIR)/usr/include
MAKE_INSTALL_FLAGS += prefix=/usr libdir=/usr/lib includedir=/usr/include

define Package/quasselc
    SECTION:=libs
    CATEGORY:=Libraries
    DEPENDS:=+glib2
    SUBMENU:=Instant Messaging
    URL:=https://github.com/phhusson/QuasselC
    TITLE:=API to access a Quassel Core in pure C
endef

define Package/quasselc/description
  An implementation of the Quassel protocol in pure C.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/quasselc
	$(CP) $(PKG_INSTALL_DIR)/usr/include/quasselc/* $(1)/usr/include/quasselc/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libquasselc.so* $(1)/usr/lib/
	$(LN) libquasselc.so.0 $(1)/usr/lib/libquasselc.so

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/quasselc.pc $(1)/usr/lib/pkgconfig/
endef

define Package/quasselc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libquasselc.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,quasselc))
