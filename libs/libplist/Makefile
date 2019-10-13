#
# Copyright (C) 2012-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libplist
PKG_VERSION:=2.0.0
PKG_RELEASE:=5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://www.libimobiledevice.org/downloads
PKG_HASH:=3a7e9694c2d9a85174ba1fa92417cfabaea7f6d19631e544948dc7e17e82f602

PKG_MAINTAINER:=Lukasz Baj <l.baj@radytek.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING.LESSER

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/libplist/Default
  TITLE:=Apple property list
  URL:=https://www.libimobiledevice.org/
endef

define Package/libplist/Default/description
  A library to handle Apple Property List format whereas it's binary or XML
endef

define Package/libplist
  $(call Package/libplist/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libxml2
  TITLE+= library
endef

define Package/libplist/description
  $(call Package/libplist/Default/description)
endef

define Package/libplistcxx
  $(call Package/libplist/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libplist $(CXX_DEPENDS)
  TITLE+= C++ library
endef

define Package/libplistcxx/description
  $(call Package/libplist/Default/description)
  This package contains the libplist C++ shared library.
endef

define Package/libplist-utils
  $(call Package/libplist/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libplist
  TITLE+= converter
endef

define Package/libplist-utils/description
  $(call Package/libplist/Default/description)
  This package contains the libplist utilities.
endef

CONFIGURE_ARGS += \
	--without-cython

TARGET_CFLAGS += -flto
TARGET_CXXFLAGS += -std=c++11 -fno-rtti
TARGET_LDFLAGS += -Wl,--gc-sections

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/plist $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libplist*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libplist*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libplist/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libplist.so.* $(1)/usr/lib/
endef

define Package/libplistcxx/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libplist++.so.* $(1)/usr/lib/
endef

define Package/libplist-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/plistutil $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libplist))
$(eval $(call BuildPackage,libplistcxx))
$(eval $(call BuildPackage,libplist-utils))
